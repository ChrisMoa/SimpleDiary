// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class SimpleInputDataWidget extends StatefulWidget {
  final String mapKey;
  String value = '';
  final bool shouldNotBeEmpty;
  final bool extendedItem;
  final bool obscureText;

  SimpleInputDataWidget(
      {required this.mapKey,
      value,
      shouldNotBeEmpty,
      extendedItem,
      obscureText,
      super.key})
      : value = value ?? '',
        shouldNotBeEmpty = shouldNotBeEmpty ?? true,
        extendedItem = extendedItem ?? false,
        obscureText = obscureText ?? false;

  @override
  State<SimpleInputDataWidget> createState() => _SimpleInputDataWidgetState();
}

class _SimpleInputDataWidgetState extends State<SimpleInputDataWidget> {
  late bool _visibleObscureText;

  @override
  void initState() {
    widget.obscureText
        ? _visibleObscureText = false
        : _visibleObscureText = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(widget.mapKey),
        ),
        Expanded(
          flex: 5,
          child: TextFormField(
            maxLines: 1,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
            decoration: InputDecoration(
              border: const UnderlineInputBorder(),
              hintText: 'Add ${widget.mapKey}',
            ),
            validator: (value) {
              if (!widget.shouldNotBeEmpty) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a valid ${widget.mapKey}';
              }
              return null;
            },
            initialValue: widget.value,
            obscureText: !_visibleObscureText,
            onSaved: (newValue) {
              assert(
                  !widget.shouldNotBeEmpty ||
                      (newValue != null && newValue != ''),
                  '${widget.mapKey} is empty');
              widget.value = newValue!;
            },
          ),
        ),
        SizedBox(
          width: 30,
          child: widget.obscureText
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _visibleObscureText = !_visibleObscureText;
                    });
                  },
                  icon: const Icon(Icons.remove_red_eye),
                )
              : const Text(''),
        ),
      ],
    );
  }
}
