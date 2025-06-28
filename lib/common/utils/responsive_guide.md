# Hướng dẫn sử dụng Responsive Design trong ứng dụng

## 1. ResponsiveUtils

Đây là lớp chính cho các công cụ responsive. Cung cấp các phương thức tĩnh để:

```dart
// Lấy kích thước màn hình
double width = ResponsiveUtils.screenWidth(context);
double height = ResponsiveUtils.screenHeight(context);

// Lấy kích thước dựa trên tỷ lệ phần trăm của màn hình
double widthPercent = ResponsiveUtils.wp(context, 10); // 10% chiều rộng màn hình
double heightPercent = ResponsiveUtils.hp(context, 5); // 5% chiều cao màn hình

// Điều chỉnh font size theo tỷ lệ màn hình
double fontSize = ResponsiveUtils.sp(context, 16); // font size 16 điều chỉnh theo màn hình

// Kiểm tra loại thiết bị
if (ResponsiveUtils.isPhone(context)) {
  // UI cho điện thoại
} else if (ResponsiveUtils.isTablet(context)) {
  // UI cho tablet
} else if (ResponsiveUtils.isDesktop(context)) {
  // UI cho desktop
}

// Kiểm tra hướng màn hình
if (ResponsiveUtils.isPortrait(context)) {
  // UI cho màn hình dọc
} else {
  // UI cho màn hình ngang
}

// Lấy padding responsive dựa theo kích thước màn hình
EdgeInsets padding = ResponsiveUtils.getResponsivePadding(context);

// Điều chỉnh theme text theo kích thước màn hình
TextTheme responsiveTextTheme = ResponsiveUtils.getResponsiveTextTheme(context, Theme.of(context).textTheme);
```

## 2. ResponsiveWidgetExtension

Cung cấp các phương thức mở rộng tiện lợi cho widget:

```dart
// Thêm padding responsive
Text('Hello').paddingAll(context, 5);
Container().paddingHorizontal(context, 3).paddingVertical(context, 2);
Row().paddingOnly(context, left: 2, right: 2, top: 1, bottom: 1);

// Thêm margin responsive
Text('Hello').marginAll(context, 5);
Container().marginHorizontal(context, 3).marginVertical(context, 2);
Row().marginOnly(context, left: 2, right: 2, top: 1, bottom: 1);

// Đặt kích thước tương đối
Container().withWidth(context, 80); // 80% chiều rộng màn hình
Container().withHeight(context, 50); // 50% chiều cao màn hình

// Điều chỉnh font size cho Text
Text('Hello').withResponsiveText(context, fontSize: 16, fontWeight: FontWeight.bold);

// UI khác nhau cho các loại thiết bị
Container().responsive(
  context,
  phone: (ctx) => Text('Phone UI'),
  tablet: (ctx) => Row(children: [Text('Tablet UI')]),
  desktop: (ctx) => Row(children: [Text('Desktop UI')]),
);
```

## 3. ResponsiveScaffold

Widget Scaffold điều chỉnh theo kích thước màn hình:

```dart
ResponsiveScaffold(
  appBar: AppBar(title: Text('My App')),
  body: Column(
    children: [
      Text('Hello World'),
      // Các widget khác
    ],
  ),
  maxContentWidth: 800, // Giới hạn chiều rộng tối đa trên tablet/desktop
  bottomNavigationBar: BottomNavigationBar(...),
);
```

## 4. ResponsiveListView và ResponsiveGridView

Các widget danh sách điều chỉnh theo kích thước màn hình:

```dart
// ListView responsive
ResponsiveListView(
  children: [
    Text('Item 1'),
    Text('Item 2'),
    // Các item khác
  ],
  maxWidth: 600, // Giới hạn chiều rộng tối đa
  itemSpacing: 10, // Khoảng cách giữa các item
);

// GridView responsive
ResponsiveGridView(
  children: [
    Card(child: Text('Item 1')),
    Card(child: Text('Item 2')),
    // Các item khác
  ],
  // crossAxisCount tự động điều chỉnh theo kích thước màn hình
);
```

## 5. Tích hợp vào UI hiện tại

Khi muốn điều chỉnh UI hiện tại:

1. Thay `const` với `final` khi sử dụng giá trị responsive
2. Thay các giá trị cứng bằng các phương thức của ResponsiveUtils
3. Sử dụng ResponsiveScaffold thay cho Scaffold thông thường

Ví dụ:
```dart
// Trước
const TextStyle titleStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
const EdgeInsets padding = EdgeInsets.all(16);

// Sau
final TextStyle titleStyle = TextStyle(
  fontSize: ResponsiveUtils.sp(context, 18),
  fontWeight: FontWeight.bold
);
final EdgeInsets padding = EdgeInsets.all(ResponsiveUtils.wp(context, 4));
```

## 6. Xử lý các lỗi render phổ biến

- Đảm bảo kiểm tra `mounted` trước khi gọi `setState()` trong các callback không đồng bộ
- Sử dụng `SingleChildScrollView` cho nội dung có thể lớn hơn màn hình
- Đặt `constraints` hợp lý cho các widget
- Tránh sử dụng giá trị cứng cho kích thước và padding

## 7. Kiểm thử trên nhiều thiết bị

Kiểm tra ứng dụng trên:
- Nhiều kích thước màn hình (nhỏ, trung bình, lớn)
- Cả định hướng dọc và ngang
- Nhiều mật độ pixel khác nhau
- Các thiết bị thực tế khác nhau
