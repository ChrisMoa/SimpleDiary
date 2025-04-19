import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    const version = "S01.00.001";
    const supportAddress = "implemented in future";
    const impressum = "impressum missing";
    const agb = "AGB missing";
    const dataPolicy = "data policy missing";
    const licenses = "currently licences not named";

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Version:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Text(
                  version,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // the row contains
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'contact:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Text(
                  supportAddress,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // the row contains
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Impressum:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Text(
                  impressum,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // the row contains
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'AGB:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Text(
                  agb,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // the row contains
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Data Policy:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Text(
                  dataPolicy,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // the row contains
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'licenses:',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(width: 16),
                Text(
                  licenses,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

