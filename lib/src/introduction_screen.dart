library introduction_screen;

import 'dart:async';
import 'dart:math';

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/src/model/page_view_model.dart';
import 'package:introduction_screen/src/ui/intro_button.dart';
import 'package:introduction_screen/src/ui/intro_page.dart';

class IntroductionScreen extends StatefulWidget {
  final List<PageViewModel> pages;
  final VoidCallback onDone;
  final Widget done;
  final ValueChanged<int>? onChange;
  final bool isProgress;
  final bool isProgressTap;
  final bool freeze;
  final Color? globalBackgroundColor;
  final DotsDecorator dotsDecorator;
  final int animationDuration;
  final int initialPage;
  final Curve curve;
  final Color? color;
  final Color? doneColor;

  const IntroductionScreen({
    Key? key,
    required this.pages,
    required this.onDone,
    required this.done,
    this.onChange,
    this.isProgress = true,
    this.isProgressTap = true,
    this.freeze = false,
    this.globalBackgroundColor,
    this.dotsDecorator = const DotsDecorator(),
    this.animationDuration = 350,
    this.initialPage = 0,
    this.curve = Curves.easeIn,
    this.color,
    this.doneColor,
  })  : assert(
          pages.length > 0,
          "You provide at least one page on introduction screen !",
        ),
        assert(initialPage >= 0),
        super(key: key);

  @override
  IntroductionScreenState createState() => IntroductionScreenState();
}

class IntroductionScreenState extends State<IntroductionScreen> {
  late PageController _pageController;
  double _currentPage = 0.0;

  PageController get controller => _pageController;

  @override
  void initState() {
    super.initState();
    int initialPage = min(widget.initialPage, widget.pages.length - 1);
    _currentPage = initialPage.toDouble();
    _pageController = PageController(initialPage: initialPage);
  }

  void next() {
    animateScroll(min(_currentPage.round() + 1, widget.pages.length - 1));
  }

  Future<void> animateScroll(int page) async {
    await _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: widget.animationDuration),
      curve: widget.curve,
    );
  }

  bool _onScroll(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics is PageMetrics && metrics.page != null) {
      setState(() => _currentPage = metrics.page!);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = (_currentPage.round() == widget.pages.length - 1);

    final doneBtn = IntroButton(
      child: widget.done,
      color: widget.doneColor ?? widget.color,
      onPressed: widget.onDone,
    );

    return Scaffold(
      backgroundColor: widget.globalBackgroundColor,
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView(
              controller: _pageController,
              physics: widget.freeze ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
              children: widget.pages.map((p) => IntroPage(page: p)).toList(),
              onPageChanged: widget.onChange,
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                constraints: const BoxConstraints(minHeight: 54.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  switchInCurve: Curves.easeInOut,
                  switchOutCurve: Curves.easeInOut,
                  child: isLastPage
                      ? doneBtn
                      : Center(
                          child: widget.isProgress
                              ? DotsIndicator(
                                  dotsCount: widget.pages.length,
                                  position: _currentPage,
                                  decorator: widget.dotsDecorator,
                                  onTap: widget.isProgressTap && !widget.freeze ? (pos) => animateScroll(pos.toInt()) : null,
                                )
                              : const SizedBox(),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
