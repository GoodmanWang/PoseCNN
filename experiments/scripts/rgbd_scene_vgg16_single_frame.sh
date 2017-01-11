#!/bin/bash

set -x
set -e

export PYTHONUNBUFFERED="True"
export CUDA_VISIBLE_DEVICES=$1
export LD_PRELOAD=/usr/lib/libtcmalloc.so.4

LOG="experiments/logs/rgbd_scene_vgg16_single_frame.txt.`date +'%Y-%m-%d_%H-%M-%S'`"
exec &> >(tee -a "$LOG")
echo Logging output to "$LOG"

# train FCN for single frames
time ./tools/train_net.py --gpu 0 \
  --network vgg16_convs \
  --weights data/imagenet_models/vgg16_convs.npy \
  --imdb rgbd_scene_train \
  --cfg experiments/cfgs/rgbd_scene_single_frame_vgg16.yml \
  --iters 40000

# test FCN for single frames
time ./tools/test_net.py --gpu 0 \
  --network vgg16_convs \
  --model output/rgbd_scene/rgbd_scene_train/vgg16_fcn_rgbd_single_frame_rgbd_scene_iter_40000.ckpt \
  --imdb rgbd_scene_val \
  --cfg experiments/cfgs/rgbd_scene_single_frame_vgg16.yml \
  --rig data/RGBDScene/camera.json
