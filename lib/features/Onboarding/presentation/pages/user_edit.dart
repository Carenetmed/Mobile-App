import 'dart:io';
import 'dart:typed_data';
import 'package:app_t/core/constants/app_assets.dart';
import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Onboarding/presentation/widget/bordered_listile.dart';
import 'package:app_t/shared/widgets/app_button.dart';
import 'package:app_t/shared/widgets/svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class UserEdit extends StatefulWidget {
  const UserEdit({super.key});

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  final String user = 'Dr. Lagbaja Omo Tamedu';

  Uint8List? _profileImage;
  Uint8List? _bannerImage;

  Future _profileGalleryImage() async {
    final newSelectedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (newSelectedImage == null) return;
    setState(() {
      _profileImage = File(newSelectedImage.path).readAsBytesSync();
    });
  }

  Future _profileCameraImage() async {
    final newSelectedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (newSelectedImage == null) return;
    setState(() {
      _profileImage = File(newSelectedImage.path).readAsBytesSync();
    });
  }

  Future _bannerGalleryImage() async {
    final newSelectedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (newSelectedImage == null) return;
    setState(() {
      _bannerImage = File(newSelectedImage.path).readAsBytesSync();
    });
  }

  Future _bannerCameraImage() async {
    final newSelectedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (newSelectedImage == null) return;
    setState(() {
      _bannerImage = File(newSelectedImage.path).readAsBytesSync();
    });
  }

  Future<void> _galleryPickerSheet(
    BuildContext context, {
    required void Function()? goGallery,
    required void Function()? goCamera,
  }) async {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(title: Text('Gallery'), onTap: goGallery),
              ListTile(title: Text('Camera'), onTap: goCamera),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                  Text(
                    'Welcome shall we meet you?',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pushReplacementNamed(RouteName.dashboard);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: REdgeInsets.all(4),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.kBlack,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: .3.sh,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {
                          _galleryPickerSheet(
                            context,
                            goGallery: () {
                              _bannerGalleryImage();
                              Navigator.pop(context);
                            },
                            goCamera: () {
                              _bannerCameraImage();
                              Navigator.pop(context);
                            },
                          );
                        },
                        child:
                            _bannerImage != null
                                ? Container(
                                  height: .2.sh,
                                  width: double.infinity,
                                  // margin: REdgeInsets.symmetric(
                                  //   horizontal: 8.w,
                                  // ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Image.memory(
                                    fit: BoxFit.contain,
                                    _bannerImage!,
                                  ),
                                )
                                : Container(
                                  height: .2.sh,
                                  alignment: Alignment.center,
                                  margin: REdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue11,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Edit your banner',
                                        style: TextStyle(
                                          fontSize: FontSizes.body3,
                                          fontFamily: AppFonts.montserrat,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.blue02,
                                        ),
                                      ),
                                      SizedBox(width: 5.w),
                                      SvgImage(imgName: AssetsIcon.pen),
                                    ],
                                  ),
                                ),
                      ),
                    ),

                    Align(
                      alignment: Alignment(-.6, .5),
                      child: GestureDetector(
                        onTap: () {
                          _galleryPickerSheet(
                            context,
                            goGallery: () {
                              _profileGalleryImage();
                              Navigator.pop(context);
                            },
                            goCamera: () {
                              _profileCameraImage();
                              Navigator.pop(context);
                            },
                          );
                        },
                        child:
                            _profileImage != null
                                ? CircleAvatar(
                                  radius: 50,
                                  backgroundImage: MemoryImage(_profileImage!),
                                )
                                : SvgImage(imgName: AssetsImages.profilePic),
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                user,
                style: TextStyle(
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue11,
                  fontSize: FontSizes.body3,
                ),
              ),
              SizedBox(height: 5.h),
              BorderedListile(
                btnAction1: null,
                title1: 'My interests',
                subtitle1: 'Add interests',
                btnAction2: null,
                title2: 'My speciality',
                subtitle2: 'Add speciality',
              ),
              SizedBox(height: 6.h),
              BorderedListile(
                btnAction1: null,
                title1: 'Bio',
                subtitle1: 'Write a short story about you',
                btnAction2: null,
                title2: 'Level of experience',
                subtitle2: 'Add speciality',
              ),
              SizedBox(height: .1.sh),
              CarenetButtonFilled(
                btnAction: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(RouteName.dashboard);
                },
                btnName: 'Continue',
              ),
              SizedBox(height: 5.h),
              CarenetButtonOutline(
                btnAction: () {
                  Navigator.of(
                    context,
                  ).pushReplacementNamed(RouteName.dashboard);
                },
                btnName: 'No,skip',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
