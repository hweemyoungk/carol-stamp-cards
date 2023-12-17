import 'package:flutter/material.dart';

class LoadMoreButton extends StatefulWidget {
  final Future<void> Function() onPressLoadMore;
  const LoadMoreButton({
    super.key,
    required this.onPressLoadMore,
  });

  @override
  State<LoadMoreButton> createState() => _LoadMoreButtonState();
}

class _LoadMoreButtonState extends State<LoadMoreButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const LinearProgressIndicator()
        : TextButton(
            onPressed: () async {
              if (mounted) {
                setState(() {
                  _loading = true;
                });
              }
              await widget.onPressLoadMore();
              if (mounted) {
                setState(() {
                  _loading = false;
                });
              }
            },
            child: const Text('LOAD MORE?'),
          );
  }
}
