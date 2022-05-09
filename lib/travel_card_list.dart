import 'package:flutter/material.dart';
import 'demo_data.dart';
import 'rotation_3d.dart';
import 'travel_card_renderer.dart';

class TravelCardList extends StatefulWidget {
  final List<City> cities;
  final Function onCityChange;

  const TravelCardList(
      {Key? key, required this.cities, required this.onCityChange})
      : super(key: key);

  @override
  TravelCardListState createState() => TravelCardListState();
}

class TravelCardListState extends State<TravelCardList>
    with SingleTickerProviderStateMixin {
  final double _maxRotation = 20;

  var _pageController;

  double _cardWidth = 160;
  double _cardHeight = 200;
  double _normalizedOffset = 0;
  double _prevScrollX = 0;
  bool _isScrolling = false;

  late AnimationController _tweenController;
  late Tween<double> _tween;
  late Animation<double> _tweenAnim;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //Create Controller, which starts/stops the tween, and rebuilds this widget while it's running
    _tweenController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _cardHeight = (size.height * .48).clamp(300.0, 400.0);
    _cardWidth = _cardHeight * .8;
    //Calculate the viewPort fraction for this aspect ratio, since PageController does not accept pixel based size values
    _pageController = PageController(
        initialPage: 1, viewportFraction: _cardWidth / size.width);

    //Create Tween, which defines our begin + end values
    _tween = Tween<double>(begin: -1, end: 0);
    //Create Animation, which allows us to access the current tween value and the onUpdate() callback.
    _tweenAnim = _tween.animate(
        CurvedAnimation(parent: _tweenController, curve: Curves.elasticOut))
      //Set our offset each time the tween fires, triggering a rebuild
      ..addListener(() {
        _setOffset(_tweenAnim.value);
      });

    //Create our main list
    Widget listContent = SizedBox(
      //Wrap list in a container to control height and padding
      height: _cardHeight,
      //Use a ListView.builder, calls buildItemRenderer() lazily, whenever it need to display a listItem
      child: PageView.builder(
        //Use bounce-style scroll physics, feels better with this demo
        physics: const BouncingScrollPhysics(),
        controller: _pageController,
        itemCount: 8,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) => _buildItemRenderer(i),
      ),
    );

    //Wrap our list content in a Listener to detect PointerUp events, and a NotificationListener to detect ScrollStart and ScrollUpdate
    //We have to use both, because NotificationListener does not inform us when the user has lifted their finger.
    //We can not use GestureDetector like we normally would, ListView suppresses it while scrolling.
    return Listener(
      //If the user has released a pointer, and is currently scrolling, we'll assume they're done scrolling and tween our offset to zero.
      //This is a bit of a hack, we can't be sure this event actually came from the same finger that was scrolling, but should work most of the time.
      onPointerUp: (PointerUpEvent event) {
        if (_isScrolling) {
          _isScrolling = false;
          _startOffsetTweenToZero(_tweenController, _tween);
        }
      },
      //Check the notifications bubbling up from the ListView, use them to update our currentOffset and isScrolling state
      child: NotificationListener(
        onNotification: (Notification notification) {
          //Scroll Update, add to our current offset, but clamp to -1 and 1
          if (notification is ScrollUpdateNotification) {
            if (_isScrolling) {
              double dx = notification.metrics.pixels - _prevScrollX;
              double scrollFactor = .01;
              double newOffset = (_normalizedOffset + dx * scrollFactor);
              _setOffset(newOffset.clamp(-1.0, 1.0));
            }
            _prevScrollX = notification.metrics.pixels;
            //Calculate the index closest to middle
            //_focusedIndex = (_prevScrollX / (_itemWidth + _listItemPadding)).round();
            widget.onCityChange(widget.cities.elementAt(
                _pageController.page.round() % widget.cities.length));
          }
          //Scroll Start
          else if (notification is ScrollStartNotification) {
            _isScrolling = true;
            _prevScrollX = notification.metrics.pixels;
            _tweenController.stop();
          }
          return true;
        },
        child: listContent,
      ),
    );
  }

  //Create a renderer for each list item
  Widget _buildItemRenderer(int itemIndex) {
    return Rotation3d(
      rotationY: _normalizedOffset * _maxRotation,
      //Create the actual content renderer for our list
      child: TravelCardRenderer(
        //Pass in the offset, renderer can update it's own view from there
        _normalizedOffset,
        //Pass in city path for the image asset links
        city: widget.cities[itemIndex % widget.cities.length],
        cardWidth: _cardWidth,
        cardHeight: _cardHeight,
      ),
    );
  }

  //Helper function, any time we change the offset, we want to rebuild the widget tree, so all the renderers get the new value.
  void _setOffset(double value) {
    setState(() {
      _normalizedOffset = value;
    });
  }

  //Tweens our offset from the current value, to 0
  void _startOffsetTweenToZero(
      AnimationController controller, Tween<double> tween) {
    //The first time this runs, setup our controller, tween and animation. All 3 are required to control an active animation.

    //Restart the tweenController and inject a new start value into the tween
    tween.begin = _normalizedOffset;
    controller.reset();
    tween.end = 0;
    controller.forward();
  }
}
