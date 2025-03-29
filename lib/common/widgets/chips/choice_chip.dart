import 'package:flutter/material.dart';
import 'package:t_store_app/common/widgets/custom_shapes/containers/circular_container.dart';
import 'package:t_store_app/utils/helper/helper_function.dart';
import '../../../utils/constants/colors.dart';

class TChoiceChip extends StatelessWidget {
  const TChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
  });

  final String text;
  final bool selected;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    final color = DHelperFunctions.getColor(text);
    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: color != null ? const SizedBox() : Text(text),
        selected: selected,
        onSelected: onSelected,
        labelStyle: TextStyle(color: selected ? DColor.white : null),
        avatar: color != null
            ? TCircularContainer(width: 50, height: 50, backgroundColor: color)
            : null,
        shape: color != null ? const CircleBorder() : null,
        labelPadding: color != null ? const EdgeInsets.all(0) : null,
        padding: color != null ? const EdgeInsets.all(0) : null,
        selectedColor: DColor.primary,
        backgroundColor: color,
      ),
    );
  }
}
