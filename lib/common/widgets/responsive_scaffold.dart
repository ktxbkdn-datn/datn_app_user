import 'package:flutter/material.dart';
import 'package:datn_app/common/utils/responsive_utils.dart';

/// Widget cơ sở hỗ trợ responsive cho các trang trong ứng dụng
class ResponsiveScaffold extends StatelessWidget {
  /// App bar của trang
  final PreferredSizeWidget? appBar;
  
  /// Nội dung chính của trang
  final Widget body;
  
  /// Bottom navigation bar
  final Widget? bottomNavigationBar;
  
  /// Floating action button
  final Widget? floatingActionButton;
  
  /// Vị trí của floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  
  /// Drawer (menu bên trái)
  final Widget? drawer;
  
  /// End drawer (menu bên phải)
  final Widget? endDrawer;
  
  /// Có hiển thị body phía sau app bar không
  final bool extendBodyBehindAppBar;
  
  /// Có hiển thị body phía sau bottom navigation bar không
  final bool extendBody;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Padding cho nội dung (mặc định là responsive)
  final EdgeInsetsGeometry? contentPadding;
  
  /// Giới hạn chiều rộng tối đa cho nội dung (cho tablet, desktop)
  final double? maxContentWidth;
  
  /// Xử lý khi tap bên ngoài một field để đóng keyboard
  final bool resizeToAvoidBottomInset;

  const ResponsiveScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.backgroundColor,
    this.contentPadding,
    this.maxContentWidth = 600.0,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsivePadding = contentPadding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxContentWidth ?? double.infinity,
            ),
            child: Padding(
              padding: responsivePadding,
              child: body,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      drawer: drawer,
      endDrawer: endDrawer,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}

/// Widget để hiển thị danh sách responsive
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final double? itemSpacing;
  final double? maxWidth;
  final bool center;

  const ResponsiveListView({
    Key? key,
    required this.children,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.itemSpacing,
    this.maxWidth,
    this.center = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = itemSpacing ?? ResponsiveUtils.hp(context, 2);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    final childrenWithSpacing = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      childrenWithSpacing.add(children[i]);
      if (i < children.length - 1) {
        childrenWithSpacing.add(SizedBox(height: responsiveSpacing));
      }
    }

    final listView = ListView(
      padding: responsivePadding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      children: childrenWithSpacing,
    );

    if (!center || maxWidth == null) {
      return listView;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: listView,
      ),
    );
  }
}

/// Widget để hiển thị Grid responsive
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final double? maxWidth;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.crossAxisCount,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.maxWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Xác định số cột dựa trên kích thước màn hình
    int columnsCount;
    if (crossAxisCount != null) {
      columnsCount = crossAxisCount!;
    } else {
      final width = ResponsiveUtils.screenWidth(context);
      if (width < 600) {
        columnsCount = 2; // Phone
      } else if (width < 1200) {
        columnsCount = 3; // Tablet
      } else {
        columnsCount = 4; // Desktop
      }
    }

    final aspectRatio = childAspectRatio ?? (ResponsiveUtils.isPhone(context) ? 1.0 : 1.2);
    final spacing = crossAxisSpacing ?? ResponsiveUtils.wp(context, 3);
    final vSpacing = mainAxisSpacing ?? ResponsiveUtils.hp(context, 2);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);

    final gridView = GridView.builder(
      padding: responsivePadding,
      itemCount: children.length,
      shrinkWrap: shrinkWrap,
      physics: physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnsCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: vSpacing,
      ),
      itemBuilder: (context, index) => children[index],
    );

    if (maxWidth == null) {
      return gridView;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: gridView,
      ),
    );
  }
}
