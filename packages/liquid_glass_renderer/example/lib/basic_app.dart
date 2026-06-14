import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:liquid_glass_renderer_example/shared.dart';
import 'package:liquid_glass_renderer_example/widgets/bottom_bar.dart';
import 'package:rivership/rivership.dart';

void main() {
  runApp(CupertinoApp(home: BasicApp()));
}

final settingsNotifier = ValueNotifier(
  LiquidGlassSettings(glassColor: Colors.white.withValues(alpha: 0.2)),
);

final blendNotifier = ValueNotifier(10.0);

class BasicApp extends HookWidget {
  const BasicApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tab = useState(0);
    final fake = useState(false);

    final visibility = useState(true);
    final visibilityValue = useSingleMotion(
      value: visibility.value ? 1.0 : 0.0,
      motion: Motion.smoothSpring(),
    );

    final light = AlwaysStoppedAnimation(pi / 4);

    const shadows = [
      BoxShadow(
        blurStyle: BlurStyle.outer,
        color: Color.from(alpha: 0.05, red: 0, green: 0, blue: 0),
        offset: Offset(0, 1),
        blurRadius: 2,
      ),
      BoxShadow(
        blurStyle: BlurStyle.outer,
        color: Color.from(alpha: 0.1, red: 0, green: 0, blue: 0),
        offset: Offset(0, 8),
        blurRadius: 30,
      ),
    ];

    return GestureDetector(
      onTap: () {
        SettingsSheet(
          fake: fake.value,
          blendNotifier: blendNotifier,
          settingsNotifier: settingsNotifier,
          lightAngleAnimation: light,
        ).show(context);
      },
      child: CupertinoPageScaffold(
        child: Stack(
          children: [
            if (tab.value == 1)
              _GlassListTab(fake: fake.value)
            else ...[
              CustomScrollView(
                slivers: [
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              fit: BoxFit.cover,
                              'https://picsum.photos/500/500?random=$index',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Center(
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    settingsNotifier,
                    light,
                    blendNotifier,
                  ]),
                  builder: (context, child) {
                    final settings = settingsNotifier.value.copyWith(
                      glassColor: CupertinoTheme.of(
                        context,
                      ).barBackgroundColor.withValues(alpha: 0.2),
                      visibility: visibilityValue,
                    );
                    return LiquidGlassLayer(
                      fake: fake.value,
                      useBackdropGroup: true,
                      settings: settings.copyWith(lightAngle: light.value),
                      child: LiquidGlassBlendGroup(
                        blend: blendNotifier.value,
                        child: Column(
                          spacing: 16,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 16,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      visibility.value = !visibility.value,
                                  child: LiquidStretch(
                                    child: LiquidGlass.auto(
                                      shadows: shadows,
                                      shape: LiquidRoundedSuperellipse(
                                        borderRadius: 20,
                                      ),
                                      child: GlassGlow(
                                        child: SizedBox.square(
                                          dimension: 100,
                                          child: Center(
                                            child: fake.value
                                                ? Text('FAKE')
                                                : Text('REAL'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                LiquidStretch(
                                  child: LiquidGlass.auto(
                                    shadows: shadows,
                                    shape: LiquidRoundedSuperellipse(
                                      borderRadius: 20,
                                    ),
                                    child: GlassGlow(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        child: SizedBox.square(
                                          dimension: 100,
                                          child: Center(
                                            child: fake.value
                                                ? Text('FAKE')
                                                : Text('REAL'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            LiquidStretch(
                              child: LiquidGlass.auto(
                                shadows: shadows,
                                shape: LiquidRoundedSuperellipse(
                                  borderRadius: 9000,
                                ),
                                child: GlassGlow(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    child: SizedBox(
                                      width: 400,
                                      height: 64,
                                      child: Center(
                                        child: fake.value
                                            ? Text('FAKE')
                                            : Text('REAL'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: CupertinoSwitch(
                  value: fake.value,
                  onChanged: (v) => fake.value = v,
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: LiquidGlassBottomBar(
                  fake: fake.value,
                  extraButton: LiquidGlassBottomBarExtraButton(
                    icon: CupertinoIcons.add_circled,
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute<void>(
                          builder: (context) => CupertinoPageScaffold(
                            child: SizedBox(),
                            navigationBar: CupertinoNavigationBar.large(),
                          ),
                        ),
                      );
                    },
                    label: '',
                  ),
                  tabs: [
                    LiquidGlassBottomBarTab(
                      label: 'Home',
                      icon: CupertinoIcons.home,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'List',
                      icon: CupertinoIcons.list_bullet,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'Profile',
                      icon: CupertinoIcons.person,
                    ),
                    LiquidGlassBottomBarTab(
                      label: 'Settings',
                      icon: CupertinoIcons.settings,
                    ),
                  ],
                  selectedIndex: tab.value,
                  onTabSelected: (index) {
                    tab.value = index;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Blink extends StatelessWidget {
  const Blink({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SequenceMotionBuilder(
      converter: SingleMotionConverter(),
      sequence: StepSequence.withMotions([
        (0.0, Motion.linear(Duration(seconds: 1))),
        (1.0, Motion.linear(Duration(seconds: 1))),
        (1.0, Motion.linear(Duration(seconds: 1))),
      ], loop: LoopMode.loop),
      builder: (context, value, phase, child) =>
          Opacity(opacity: value, child: child),
      child: child,
    );
  }
}

class _GlassListTab extends StatelessWidget {
  const _GlassListTab({required this.fake});

  final bool fake;

  static const _shadows = [
    BoxShadow(
      blurStyle: BlurStyle.outer,
      color: Color.from(alpha: 0.08, red: 0, green: 0, blue: 0),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
    BoxShadow(
      blurStyle: BlurStyle.outer,
      color: Color.from(alpha: 0.16, red: 0, green: 0, blue: 0),
      offset: Offset(0, 14),
      blurRadius: 36,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/wallpaper.webp', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.35),
              ],
            ),
          ),
        ),
        ListenableBuilder(
          listenable: settingsNotifier,
          builder: (context, child) {
            final settings = settingsNotifier.value.copyWith(
              glassColor: CupertinoTheme.of(
                context,
              ).barBackgroundColor.withValues(alpha: 0.18),
              blur: max(settingsNotifier.value.blur, 8),
              saturation: max(settingsNotifier.value.saturation, 1.25),
            );

            return LiquidGlassLayer(
              fake: fake,
              useBackdropGroup: true,
              settings: settings,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = min(
                    max(constraints.maxWidth - 32, 0.0),
                    560.0,
                  );

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 96, 16, 128),
                    itemCount: 28,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: width,
                          child: LiquidStretch(
                            child: LiquidGlass.auto(
                              shadows: _shadows,
                              shape: const LiquidRoundedSuperellipse(
                                borderRadius: 28,
                              ),
                              child: GlassGlow(
                                child: SizedBox(
                                  height: 82,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          _iconForIndex(index),
                                          size: 28,
                                          color: CupertinoColors.white,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Liquid Glass ${index + 1}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: CupertinoColors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Scrollable glass list item',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: CupertinoColors.white
                                                      .withValues(
                                                        alpha: 0.72,
                                                      ),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          CupertinoIcons.chevron_right,
                                          size: 18,
                                          color: CupertinoColors.white,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _iconForIndex(int index) {
    const icons = [
      CupertinoIcons.sparkles,
      CupertinoIcons.drop,
      CupertinoIcons.flame,
      CupertinoIcons.snow,
      CupertinoIcons.sun_max,
      CupertinoIcons.moon_stars,
    ];
    return icons[index % icons.length];
  }
}
