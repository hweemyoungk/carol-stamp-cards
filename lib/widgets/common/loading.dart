import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String? message;
  const Loading({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final onBgColor = Theme.of(context).colorScheme.onBackground;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: onBgColor,
          ),
          if (message != null)
            Text(
              message!,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(color: onBgColor),
            ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(),
    //   body: Center(
    //     child: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         CircularProgressIndicator(
    //           color: onBgColor,
    //         ),
    //         if (message != null)
    //           Text(
    //             message!,
    //             style: Theme.of(context)
    //                 .textTheme
    //                 .displaySmall!
    //                 .copyWith(color: onBgColor),
    //           ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
