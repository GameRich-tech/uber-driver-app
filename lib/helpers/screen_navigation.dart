import 'package:flutter/material.dart';
import 'package:page_animation_transition/animations/top_to_bottom_faded.dart';
import 'package:page_animation_transition/page_animation_transition.dart';

void changeScreen(BuildContext context, Widget widget) {
  Navigator.push(
    context,
    PageAnimationTransition(
      page: widget,
      pageAnimationType: TopToBottomFadedTransition(), // Change animation here
    ),
  );
}

void changeScreenReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(
    context,
    PageAnimationTransition(
      page: widget,
      pageAnimationType: TopToBottomFadedTransition(), // Change animation here
    ),
  );
}
