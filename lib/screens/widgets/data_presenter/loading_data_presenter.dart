import 'package:flutter/material.dart';

class LoadingDataPresenter extends StatefulWidget {
  @override
  _LoadingDataPresenterState createState() => _LoadingDataPresenterState();
}

class _LoadingDataPresenterState extends State<LoadingDataPresenter>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Color> colorAnimationOne;
  Animation<Color> colorAnimationTwo;

  @override
  void initState() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    colorAnimationOne = ColorTween(
      begin: Colors.white54,
      end: Colors.grey.withOpacity(0.8),
    ).animate(_animationController);
    colorAnimationTwo = ColorTween(
      begin: Colors.grey.withOpacity(0.8),
      end: Colors.white54,
    ).animate(_animationController);

    _animationController.forward();

    _animationController.addListener(() {
      if (_animationController.status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (_animationController.status == AnimationStatus.dismissed) {
        _animationController.forward();
      }

      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: (MediaQuery.of(context).size.height - 250) / 3,
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xff657582).withOpacity(0.17),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(5, 5),
          ),
        ],
      ),
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            colors: [
              colorAnimationOne.value,
              colorAnimationTwo.value,
            ],
          ).createShader(rect);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              flex: 7,
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
