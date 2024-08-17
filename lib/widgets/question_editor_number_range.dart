import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberRangeWidget extends StatelessWidget {
  final int minValue;
  final int maxValue;
  final Function(int) onMinChanged;
  final Function(int) onMaxChanged;

  const NumberRangeWidget({
    Key? key,
    required this.minValue,
    required this.maxValue,
    required this.onMinChanged,
    required this.onMaxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Number Range', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  Text('Minimum',
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: minValue.toString(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          onMinChanged(int.parse(value));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Text('Maximum',
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 100,
                    child: TextFormField(
                      initialValue: maxValue.toString(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          onMaxChanged(int.parse(value));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
