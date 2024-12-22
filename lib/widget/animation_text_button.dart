import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/detector_provider.dart';

class AnimatedEllipsisTextButton extends StatelessWidget {
  const AnimatedEllipsisTextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<DetectorProvider>(context);
    return Center(
      child: Column(
        children: [
          // Separate Consumer for the TextButton
          Consumer<DetectorProvider>(
            builder: (context, provider, _) => TextButton(
              onPressed: () => provider.toggleRecognition(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black,
                elevation: 4.0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                side: const BorderSide(color: Colors.grey, width: 1.0),
              ),
              child: Text(provider.buttonText),
            ),
          ),
          const SizedBox(height: 10),
          // Separate Consumer for the processing time Text
          Consumer<DetectorProvider>(
            builder: (context, provider, _) => Text(
              provider.processingTime,
              style: Theme.of(context)
                  .textTheme
                  .displaySmall!
                  .copyWith(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
