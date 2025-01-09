@echo off
REM Define dataset name
set DATASET_NAME=data

REM Convert MOV to JPG
mkdir "%DATASET_NAME%\images"
ffmpeg -i input.MOV -vf fps=1.75 "%DATASET_NAME%\images\%%04d.jpg"

REM Activate the conda environment
call conda activate gaussian_splatting

REM Directory containing the images
set image_directory=%DATASET_NAME%\images

REM Destination directory for resized images
set destination_directory=%DATASET_NAME%\images_2

REM Create the destination directory if it doesn't exist
mkdir "%destination_directory%"

REM Loop through all image files in the image directory
for %%f in ("%image_directory%\*") do (
    REM Extract the filename
    set "filename=%%~nxf"
    
    REM Define the destination file path
    set "destination_file=%destination_directory%\%filename%"
    
    REM Resize the image to 50% of its original size and save it to the destination directory
    convert -resize 50%% "%%f" "%destination_file%"
)

echo Resizing complete.

REM Use COLMAP to convert images to point cloud
echo Running COLMAP to convert images to point cloud...
python convert.py -s "%DATASET_NAME%"

REM Run the training script
echo Starting training...
python train.py -s "%DATASET_NAME%"

REM Navigate to the viewers directory and run the viewer application
cd viewers\bin
start SIBR_gaussianViewer_app -m ..\..\output\*