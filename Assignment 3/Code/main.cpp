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

const float MAX_DEPTH = 1.0; 

const int   POISSON_DEPTH = 14;
const float POISSON_SCALE = 1.25;
const int   POISSON_SAMPLES_PER_NODE = 20;

const int   MC_GRID_RESOLUTION = 100;

const float OCTREE_RESOLUTION = 0.025f;
const float FOCAL_LENGTH_MULTIPLIER = 3.8f;

// Create viewer
pcl::visualization::PCLVisualizer viewer("Simple Cloud Viewer");





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


// Change camera function
void keyboardEventOccurred(const pcl::visualization::KeyboardEvent& event, void* nothing) {
    if (event.getKeySym() == "f" && event.keyDown()) {
        viewer.setCameraPosition(0.1, 0.1, -1.8, 0.2, 0.2, 0.2, 0, -1, 0);
    }
    else if (event.getKeySym() == "b" && event.keyDown()) {
        viewer.setCameraPosition(0.1, 0.1, 2.2, 0.2, 0.2, 0.2, 0, -1, 0);
    }
    else if (event.getKeySym() == "r" && event.keyDown()) {
        viewer.setCameraPosition(-1.8, 0.1, 0.1, 0.2, 0.2, 0.2, 0, -1, 0);
    }
    else if (event.getKeySym() == "l" && event.keyDown()) {
        viewer.setCameraPosition(2.2, 0.1, 0.1, 0.2, 0.2, 0.2, 0, -1, 0);
    }
    else if (event.getKeySym() == "t" && event.keyDown()) {
        viewer.setCameraPosition(0.1, -1.8, 0.1, 0.2, 0.2, 0.2, 0, -1, 0);
    }
}


// Helper function used to visualize the mesh
void visualise (pcl::PolygonMesh &triangles) {

    // Add mesh
    viewer.addPolygonMesh(triangles, "meshes", 0);

    // Define viewer parameters
    viewer.setBackgroundColor(1, 1, 1);
    viewer.addCoordinateSystem(1.0);
    viewer.initCameraParameters ();

    // Set initial camera position
    viewer.setCameraPosition(0.1, 0.1, -1.2, 0.2, 0.2, 0.2, 0, -1, 0);

    viewer.registerKeyboardCallback(&keyboardEventOccurred, (void*) NULL);

    // Keep viewer open
    while (!viewer.wasStopped()){
        viewer.spinOnce(100);
        boost::this_thread::sleep (boost::posix_time::microseconds (100000));
    }
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

            // Define Poisson's parameters.
            poisson.setDepth(POISSON_DEPTH);
            poisson.setScale(POISSON_SCALE);
            poisson.setSamplesPerNode(POISSON_SAMPLES_PER_NODE);

            // Create actual mesh.
            poisson.reconstruct(triangles);
            break;
        }
        case MarchingCubes: {
            pcl::MarchingCubesHoppe<pcl::PointNormal> marchingCubes;

            // Set input to the Marching Cubes method.
            marchingCubes.setInputCloud(pointCloud);

            // Define Marching Cube's parameters.
            marchingCubes.setGridResolution(MC_GRID_RESOLUTION, MC_GRID_RESOLUTION, MC_GRID_RESOLUTION);

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


// Helper struct, used in computing vertices' colour.
struct point {
    bool empty = true;
    std::vector<uint8_t> r;
    std::vector<uint8_t> g;
    std::vector<uint8_t> b;
} ;


// Function used to determine vertice colour, given colour observed in each frame.
uint8_t averageOf3Closest(std::vector<uint8_t> colour_channel) {
    std::vector<uint8_t> best(3);
    int smallest_dist = 1000; // Anything bigger than the max possible value for the sum of distances between 3 [0-255] values

    // This next bit can definitely be made faster, but not in the mood for it now.
    // Also, there is no guarantee whatsoever that the point will have colour for at least 3 frames, so this would break
    // in those situations. However, that doesn't seem to be the case with these specific images, thus we didn't code for it.
    for (uint8_t value1 : colour_channel) {
        for (uint8_t value2 : colour_channel) {
            for (uint8_t value3 : colour_channel) {
                if (&value1 != &value2  && &value1 != &value3 && &value2 != &value3) {
                    int current_val = abs(value1-value2) + abs(value1-value3) + abs(value2-value3);
                    if (current_val < smallest_dist) {
                        smallest_dist = current_val;
                        best[0] = value1;
                        best[1] = value2;
                        best[2] = value3;
                    }
                }
            }
        }
    }

    return std::accumulate(best.begin(), best.end(), 0.0)/(uint8_t)best.size();
}


// Function that adds texture to an existing mesh.
pcl::PolygonMesh addTextureFromMesh(pcl::PolygonMesh &mesh, Frame3D frames[]) {

    pcl::TextureMapping<pcl::PointXYZ> map;

    pcl::PointCloud<pcl::PointXYZ>::Ptr meshPointCloud(new pcl::PointCloud<pcl::PointXYZ>);
    pcl::fromPCLPointCloud2(mesh.cloud, *meshPointCloud);

    std::vector<point> cloudPointColours(meshPointCloud->size());

    for (int i = 0; i < 8; i++) {
        std::cout << boost::format("Texturing from frame %d") % i << std::endl;

        Frame3D frame = frames[i];

        // Get camera parameters
        pcl::TextureMapping<pcl::PointXYZ>::Camera camera;
        camera.focal_length = frame.focal_length_*FOCAL_LENGTH_MULTIPLIER; //For some reason works better with this multiplier
        camera.pose = frame.getEigenTransform();
        camera.width = frame.rgb_image_.cols;
        camera.height = frame.rgb_image_.rows;

        pcl::PointCloud<pcl::PointXYZ>::Ptr tempPointCloud(new pcl::PointCloud<pcl::PointXYZ>);
        pcl::copyPointCloud(*meshPointCloud, *tempPointCloud);

        // Compute transformed point cloud.
        pcl::transformPointCloud(*tempPointCloud, *tempPointCloud, camera.pose.inverse());

        // Octree for occlusion determination
        pcl::TextureMapping<pcl::PointXYZ>::Octree::Ptr octree(new pcl::TextureMapping<pcl::PointXYZ>::Octree(OCTREE_RESOLUTION));
        octree->setInputCloud(tempPointCloud);
        octree->addPointsFromInputCloud();

        for (auto polygon : mesh.polygons) {
            for (auto vertice : polygon.vertices) {

                pcl::PointXYZ temp_point;
                temp_point.x = tempPointCloud->points.at(vertice).x;
                temp_point.y = tempPointCloud->points.at(vertice).y;
                temp_point.z = tempPointCloud->points.at(vertice).z;

                // Determine if point is occluded
                if (!map.isPointOccluded(temp_point, octree)) {

                    // Determine if point is visible in RGB image
                    Eigen::Vector2f coordinates;
                    if (map.getPointUVCoordinates(temp_point, camera, coordinates)) {
                        int x = (int)(coordinates[0] * camera.width);
                        int y = (int)(camera.height - (coordinates[1] * camera.height));

                        // Pushback vertice's rgb, for current frame, to vector<struct> of observed RGBs.
                        cv::Vec3b bgrPixel = frame.rgb_image_.at<cv::Vec3b>(y, x);
                        cloudPointColours[vertice].r.push_back((uint8_t)bgrPixel[2]);
                        cloudPointColours[vertice].g.push_back((uint8_t)bgrPixel[1]);
                        cloudPointColours[vertice].b.push_back((uint8_t)bgrPixel[0]);
                    }
                }
            }
        }
    }

    // Compute each vertice's colour
    pcl::PointCloud<pcl::PointXYZRGB>::Ptr colouredPointCloud(new pcl::PointCloud<pcl::PointXYZRGB>);
    pcl::fromPCLPointCloud2(mesh.cloud, *colouredPointCloud);

    for (auto polygon : mesh.polygons) {
            for (auto vertice : polygon.vertices) {
                colouredPointCloud->points.at(vertice).r = averageOf3Closest(cloudPointColours[vertice].r);
                colouredPointCloud->points.at(vertice).g = averageOf3Closest(cloudPointColours[vertice].g);
                colouredPointCloud->points.at(vertice).b = averageOf3Closest(cloudPointColours[vertice].b);
            }
    }

    pcl::toPCLPointCloud2(*colouredPointCloud, mesh.cloud);

    return mesh;
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

    std::cout << "Visualizer opens immediately, but only shows anything at the end." << std::endl;
    std::cout << "Once it starts showing, key presses can be used to change the camera:" << std::endl;
    std::cout << "'f' - front, 'b' - back, 'r' - right, 'l' - left, 't' - top" << std::endl;
    std::cout << "Note: Leaving the mouse pointer within the visualizer window might cause weird behaviour." << std::endl << std::endl;

    // Determine the specified reconstruction method
    const CreateMeshMethod reconMode = static_cast<CreateMeshMethod>(std::stoi(argv[2]));

    // Load 3D frames
    Frame3D frames[8];
    for (int i = 0; i < 8; ++i) {
        frames[i].load(boost::str(boost::format("%s/%05d.3df") % argv[1] % i));
    }

    pcl::PointCloud<pcl::PointNormal>::Ptr pointCloud;
    pcl::PolygonMesh triangles;


    // SECTION 3 & 4 (part common to both): 3D Meshing & Watertighting

    // Create one point cloud by merging all frames.
    pointCloud = mergingPointClouds(frames);

    // Create a mesh from the cloud, using a reconstruction method,
    // Poisson Surface or Marching Cubes
    triangles = createMesh(pointCloud, reconMode);

    // SECTION 3 --> finishes here. Nothing more required.

    // SECTION 4: Coloring 3D Model
    if (argv[3][0] == 't')
        triangles = addTextureFromMesh(triangles, frames);


    /***************VISUALIZATION**************/

    std::cout << "Finished texturing" << std::endl;
    visualise(triangles);

    return 0;
}