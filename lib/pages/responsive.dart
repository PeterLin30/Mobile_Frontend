import 'package:flutter/material.dart';

/// Batas lebar layar (dalam dp) untuk berpindah layout.
/// < 600  : HP portrait (compact)
/// >= 600 : HP landscape / tablet (wide)
const double kWideBreakpoint = 600;

extension ResponsiveContext on BuildContext {
  /// Ukuran layar saat ini (ikut berubah saat rotasi).
  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// true untuk HP landscape dan tablet.
  bool get isWide => screenSize.width >= kWideBreakpoint;
}

/// Membatasi lebar konten dan menengahkannya.
/// Dipakai untuk form, detail, dan daftar supaya tidak melebar di layar besar.
class ResponsiveBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveBody({super.key, required this.child, this.maxWidth = 720});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final width = box.maxWidth < maxWidth ? box.maxWidth : maxWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        );
      },
    );
  }
}

/// Dua panel: berdampingan (Row) saat layar lebar, bertumpuk (Column)
/// saat layar sempit. Dipakai di dalam widget yang bisa di-scroll.
class AdaptiveSplit extends StatelessWidget {
  final Widget primary;
  final Widget secondary;
  final double breakpoint;
  final double gap;
  final int primaryFlex;
  final int secondaryFlex;

  const AdaptiveSplit({
    super.key,
    required this.primary,
    required this.secondary,
    this.breakpoint = 560,
    this.gap = 16,
    this.primaryFlex = 1,
    this.secondaryFlex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: primaryFlex, child: primary),
              SizedBox(width: gap),
              Expanded(flex: secondaryFlex, child: secondary),
            ],
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [primary, SizedBox(height: gap), secondary],
        );
      },
    );
  }
}

/// Jumlah kolom berdasarkan lebar yang tersedia.
int columnsFor(
  double availableWidth, {
  required double minTileWidth,
  double spacing = 12,
  int maxColumns = 3,
}) {
  final n = ((availableWidth + spacing) / (minTileWidth + spacing)).floor();
  return n.clamp(1, maxColumns);
}

/// Daftar kartu adaptif: 1 kolom di HP portrait, 2-3 kolom di layar lebar.
/// Tinggi kartu mengikuti isinya (tidak perlu tinggi tetap), dan kartu dalam
/// satu baris otomatis sama tinggi.
class ResponsiveCardList extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsets padding;
  final double minTileWidth;
  final double spacing;
  final int maxColumns;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveCardList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
    this.minTileWidth = 340,
    this.spacing = 12,
    this.maxColumns = 3,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = columnsFor(
          box.maxWidth - padding.horizontal,
          minTileWidth: minTileWidth,
          spacing: spacing,
          maxColumns: maxColumns,
        );

        if (cols == 1) {
          return ListView.separated(
            padding: padding,
            shrinkWrap: shrinkWrap,
            physics: physics,
            itemCount: itemCount,
            separatorBuilder: (_, __) => SizedBox(height: spacing),
            itemBuilder: itemBuilder,
          );
        }

        final rows = (itemCount / cols).ceil();
        return ListView.separated(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: rows,
          separatorBuilder: (_, __) => SizedBox(height: spacing),
          itemBuilder: (context, row) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int c = 0; c < cols; c++) ...[
                    if (c > 0) SizedBox(width: spacing),
                    Expanded(
                      child: row * cols + c < itemCount
                          ? itemBuilder(context, row * cols + c)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
