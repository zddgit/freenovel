import 'package:flutter/material.dart';
import 'package:freenovel/util/Tools.dart';
import 'package:freenovel/views/ChapterDetail.dart';

class CoustomSlider extends StatefulWidget{
  final State state;

  CoustomSlider(this.state);

  @override
  State<StatefulWidget> createState() {
    return CoustomSliderState(this.state);
  }

}
class CoustomSliderState extends State<CoustomSlider>{
  int fontsize=16;
  State state;

  CoustomSliderState(this.state);

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: (state is ChapterDetailState)?(state as ChapterDetailState).fontsize.toDouble():fontsize.toDouble(),
      min: 16,
      max: 32,
      onChanged: (value){
        fontsize = value.toInt();
        Tools.updateUI(this);
        if(state is ChapterDetailState){
          (state as ChapterDetailState).fontsize = fontsize;
          (state as ChapterDetailState).updateFontSize();
        }
      },
    );
  }

}