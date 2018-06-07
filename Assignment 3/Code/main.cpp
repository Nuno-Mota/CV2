/*
 * main.cpp
 *
 *  Created on: 28 May 2016
 *      Author: Minh Ngo @ 3DUniversum
 */
#include <iostream>
#include <boost/format.hpp>

#include <pcl/point_types.h>
#include <pcl/point_cloud.h>
#include <pcl/features/integral_image_normal.h>
#include <pcl/visualization/pcl_visualizer.h>
#include <pcl/common/transforms.h>
#include <pcl/kdtree/kdtree_flann.h>
#include <pcl/surface/marching_cubes.h>
#include <pcl/surface/marching_cubes_rbf.h>
#include <pcl/surface/marching_cubes_hoppe.h>
#include <pcl/filters/passthrough.h>
#include <pcl/surface/poisson.h>
#include <pcl/surface/impl/texture_mapping.hpp>
#include <pcl/features/normal_3d_omp.h>
#include <pcl/surface/vtk_smoothing/vtk_utils.h>

#include <eigen3/Eigen/Core>

#include <opencv2/opencv.hpp>
#include <opencv2/core/mat.hpp>
#include <opencv2/core/eigen.hpp>

#include <vtkSmartPointer.h>

#include "Frame3D/Frame3D.h"


/********************************************
 * **************************************** *
 * ********* CONSTANTS DEFINITION ********* *
 * **************************************** *
 ********************************************/
// TODO: Pick good values (how?)
const float MAX_DEPTH = 1; // 

const int POISSON_DEPTH = 12;
const float POISSON_SCALE = 1.75;
const int   POISSON_SAMPLES_PER_NODE = 20;





/********************************************
 * **************************************** *
 * ********** AUXILIAR FUNCTIONS ********** *
 * **************************************** *
 ********************************************/

// This function extracts a point cloud from a given depth image.
pcl::PointCloud<pcl::PointNormal>::Ptr getPointCloud(const cv::Mat& depthImage, const float focal_length, const float max_depth) {
    
    assert(depthImage.type() == CV_16U);

    pcl::PointCloud<pcl::PointNormal>::Ptr point_cloud(new pcl::PointCloud<pcl::PointNormal>());

    const int half_width = depthImage.cols / 2;
    const int half_height = depthImage.rows / 2;
    const float inv_focal_length = 1.0 / focal_length;

    point_cloud->points.reserve(depthImage.rows * depthImage.cols);
    
    for (int y = 0; y < depthImage.rows; y++) {
        for (int x = 0; x < depthImage.cols; x++) {
            float z = depthImage.at<ushort>(cv:: Point(x, y)) * 0.001;

            pcl::PointNormal point;
            point.x = static_cast<float>(x - half_width)  * z * inv_focal_length;
            point.y = static_cast<float>(y - half_height) * z * inv_focal_length;

            if (z < max_depth && z > 0) {
                point.z = z;
                point_cloud->points.emplace_back(point);
            } else {
                point.z = NAN;
                point_cloud->points.emplace_back(point);
            }
        }
    }

    point_cloud->width = depthImage.cols;
    point_cloud->height = depthImage.rows;
    return point_cloud;
}


// This function computes normals given a point cloud.
// !! Please note that you should remove NaN values from the pointcloud after computing the surface normals.
void computeNormals(pcl::PointCloud<pcl::PointNormal>::Ptr cloud) {
    
    pcl::IntegralImageNormalEstimation<pcl::PointNormal, pcl::PointNormal> ne;
    ne.setNormalEstimationMethod(ne.AVERAGE_3D_GRADIENT);
    ne.setMaxDepthChangeFactor(0.02f);
    ne.setNormalSmoothingSize(10.0f);
    ne.setInputCloud(cloud);
    ne.compute(*cloud);
}





/********************************************
 * **************************************** *
 * ********** BACKBONE FUNCTIONS ********** *
 * **************************************** *
 ********************************************/

// This function extracts a point cloud from each frame and merges all frames' point clouds into one point cloud.
pcl::PointCloud<pcl::PointNormal>::Ptr mergingPointClouds(Frame3D frames[]) {
    pcl::PointCloud<pcl::PointNormal>::Ptr modelCloud(new pcl::PointCloud<pcl::PointNormal>);

    for (int i = 0; i < 8; i++) {
        std::cout << boost::format("Merging frame %d") % i << std::endl;

        Frame3D frame = frames[i];
        cv::Mat depthImage = frame.depth_image_;
        double focalLength = frame.focal_length_;
        const Eigen::Matrix4f cameraPose = frame.getEigenTransform();

        // Get curent frame's point cloud (pointer).
        pcl::PointCloud<pcl::PointNormal>::Ptr current_pc = getPointCloud(depthImage, focalLength, MAX_DEPTH);

        // Compute curent frame's point cloud's normals.
        computeNormals(current_pc);

        // Compute transformed normals.
        pcl::transformPointCloudWithNormals(*current_pc, *current_pc, cameraPose);
        
        // Remove NaNs from the point cloud.
        std::vector<int> idxs;
        pcl::removeNaNNormalsFromPointCloud(*current_pc, *current_pc, idxs);

        *modelCloud += *current_pc;
    }

    return modelCloud;
}


// Different methods of constructing mesh
enum CreateMeshMethod { PoissonSurfaceReconstruction = 0, MarchingCubes = 1};

// Create a mesh from a given point cloud, using one of the methods above.
pcl::PolygonMesh createMesh(pcl::PointCloud<pcl::PointNormal>::Ptr pointCloud, CreateMeshMethod method) {
    std::cout << "Creating meshes" << std::endl;

    // The variable for the constructed mesh
    pcl::PolygonMesh triangles;

    switch (method) {
        case PoissonSurfaceReconstruction: {
            pcl::Poisson<pcl::PointNormal> poisson;

            // Set input to the Poisson method.
            poisson.setInputCloud(pointCloud);

            // Define Poisson's parameters. (other parameters seemed a bit complicated to exactly
            // understand what their purpose was, and were assumed to be out of the scope of the project).
            poisson.setDepth(POISSON_DEPTH);
            poisson.setScale(POISSON_SCALE);
            poisson.setSamplesPerNode(POISSON_SAMPLES_PER_NODE);

            // Create actual mesh.
            poisson.reconstruct(triangles);
            break;
        }
        case MarchingCubes: {
            // How to choose between "Hoppe" and "RBF"?
            pcl::MarchingCubesHoppe<pcl::PointNormal> marchingCubes;
            //pcl::MarchingCubesRBF<pcl::PointXYZRGBNormal> marchingCubes;

            // Set input to the Marching Cubes method.
            marchingCubes.setInputCloud(pointCloud);

            // Define Marching Cube's parameters.
            //marchingCubes.setDistanceIgnore(20.0f); // Cannot find this function, for some weird reason.
            marchingCubes.setGridResolution (30, 30, 30);
            //marchingCubes.setIsoLevel (0.5f);

            // Set Marching Cube's search method.
            pcl::search::KdTree<pcl::PointNormal>::Ptr search_tree (new pcl::search::KdTree<pcl::PointNormal>);
            search_tree->setInputCloud(pointCloud);
            marchingCubes.setSearchMethod(search_tree);

            // Create actual mesh.
            marchingCubes.reconstruct(triangles);
            break;
        }
    }
    return triangles;
}





/********************************************
 * **************************************** *
 * ***************** MAIN ***************** *
 * **************************************** *
 ********************************************/

int main(int argc, char *argv[]) {

    // Verify arguments
    if (argc != 4) {
        std::cout << "./final [3DFRAMES PATH] [RECONSTRUCTION MODE] [TEXTURE_MODE]" << std::endl;

        return 0;
    }

    // Determine the specified reconstruction method
    const CreateMeshMethod reconMode = static_cast<CreateMeshMethod>(std::stoi(argv[2]));

    // Load 3D frames
    Frame3D frames[8];
    for (int i = 0; i < 8; ++i) {
        frames[i].load(boost::str(boost::format("%s/%05d.3df") % argv[1] % i));
    }

    pcl::PointCloud<pcl::PointNormal>::Ptr pointCloud;
    pcl::PolygonMesh triangles;

    // Create one point cloud by merging all frames.
    pointCloud = mergingPointClouds(frames);

    // Create a mesh from the cloud, using a reconstruction method,
    // Poisson Surface or Marching Cubes
    triangles = createMesh(pointCloud, reconMode);
    // TODO: Add normals to mesh!

    // SECTION 3: 3D Meshing & Watertighting --> finishes here. Nothing more required.

    // SECTION 4: Coloring 3D Model
    if (argv[3][0] == 't') {}//addTextureFromMesh(triangles, frames);}




    /***************VISUALIZATION**************/

    std::cout << "Finished texturing" << std::endl;

    // Create viewer
    boost::shared_ptr<pcl::visualization::PCLVisualizer> viewer(new pcl::visualization::PCLVisualizer("3D Viewer"));

    /* if (argv[3][0] == 'a') { // TODO: change to correct letter, 't'
        // SECTION 4: Coloring 3D Model
        // Add colored point cloud to viewer, because it does not support colored meshes
        pcl::visualization::PointCloudColorHandlerRGBField<pcl::PointXYZRGBNormal> rgb(pointCloud);
        viewer->addPointCloud<pcl::PointXYZRGBNormal>(pointCloud, rgb, "cloud");
    } */

    // Add mesh
    viewer->setBackgroundColor(1, 1, 1);

    // Configure viewer
    vtkSmartPointer<vtkPolyData> poly_data;
    pcl::VTKUtils::mesh2vtk(triangles, poly_data);
    viewer->addModelFromPolyData(poly_data, "poly_data", 0);
    viewer->setShapeRenderingProperties(pcl::visualization::PCL_VISUALIZER_SHADING,
                                        pcl::visualization::PCL_VISUALIZER_SHADING_PHONG, "poly_data");
    viewer->addCoordinateSystem(1.0);
    viewer->initCameraParameters();

    // Set initial camera position
    viewer->setCameraPosition(0.1, 0.1, -1.2, 0.2, 0.2, 0.2, 0, -1, 0);

    // Keep viewer open
    while (!viewer->wasStopped()) {
        viewer->spinOnce(100);
        boost::this_thread::sleep(boost::posix_time::microseconds(100000));
    }

    return 0;
}