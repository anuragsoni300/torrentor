import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

Future showMyDialog(BuildContext context) async {
  var status = await Permission.manageExternalStorage.status;
  if (status != PermissionStatus.granted) {
    return Future.sync(
      () => showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          return GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 70.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Theme.of(context).colorScheme.background,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "You need to give permission for managing files to download torrent.",
                        style: GoogleFonts.comfortaa(
                          textStyle: TextStyle(
                            fontSize: 10.sp,
                            color: Theme.of(context).colorScheme.background ==
                                    const Color.fromRGBO(242, 242, 242, 1)
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          height: 1.7,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          Permission.manageExternalStorage.request();
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: 2.h, bottom: 0.4.h, left: 4.w, right: 4.w),
                          child: Card(
                            elevation: 15,
                            color: Theme.of(context).colorScheme.background ==
                                    const Color.fromRGBO(242, 242, 242, 1)
                                ? Colors.black
                                : Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 1.h, bottom: 1.h, left: 8.w, right: 8.w),
                              child: Text(
                                'Allow',
                                style: GoogleFonts.comfortaa(
                                  textStyle: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                                .colorScheme
                                                .background !=
                                            const Color.fromRGBO(
                                                242, 242, 242, 1)
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  } else {
    return false;
  }
}
