# Kiến trúc ứng dụng khách hàng

Repository này có thể build độc lập. Mã nguồn được tổ chức theo chức năng, với ranh giới rõ ràng giữa phần lắp ghép dependency, giao diện, dữ liệu và hạ tầng. Dự án giữ cơ chế ChangeNotifier sẵn có của Flutter cùng các dependency HTTP hiện tại. Không bổ sung framework quản lý trạng thái mới hay lớp domain/use-case khi chưa có nhu cầu thực tế.

```text
lib/
  main.dart                                  Chỉ chứa điểm khởi chạy
  app/
    bootstrap.dart                           Quản lý vòng đời controller và HTTP
    customer_app.dart                        MaterialApp và bản địa hóa tiếng Việt
    theme/app_theme.dart                     Màu sắc và ThemeData
    navigation/customer_shell.dart           Kiểm tra phiên, tab, làm mới và hộp thoại đăng xuất
    session/customer_session_controller.dart Danh tính và vòng đời phiên trên toàn ứng dụng
    session/widgets/email_verification.dart  UI xác thực phiên dùng chung
  core/
    config/app_config.dart                   Cấu hình API_BASE_URL khi build
    errors/api_exception.dart                Hợp đồng lỗi API
    network/
      json.dart                              Hợp đồng kiểu map JSON cho HTTP
      api_client.dart                        Truyền tải HTTP, phản hồi bao ngoài, ánh xạ thời gian chờ/lỗi
    storage/
      token_store.dart                       Hợp đồng lưu trữ có thể truyền implementation vào
      secure_token_store.dart                Triển khai lưu trữ bảo mật trên thiết bị
  features/
    auth/
      presentation/
        screens/auth_screen.dart             Đăng nhập, đăng ký, khôi phục/đặt lại mật khẩu
    home/presentation/
      screens/home_screen.dart                Lời chào và khám phá dịch vụ
      widgets/service_card.dart               Tóm tắt dịch vụ dành riêng cho trang chủ
    orders/presentation/screens/orders_screen.dart
                                              Màn hình thông báo rõ chức năng đặt chuyến chưa khả dụng
    account/presentation/screens/account_screen.dart
                                              Hồ sơ, xác thực và thao tác đăng xuất
  shared/
    widgets/brand.dart                        Nhận diện thương hiệu khách hàng dùng ở các màn hình
    widgets/panel.dart                        Khung nội dung có thể tái sử dụng
    widgets/notice.dart                       Thành phần thông báo có thể tái sử dụng
    validation/form_validators.dart           Hàm kiểm tra trường bắt buộc dùng lại
test/
  api_test.dart                              Kiểm thử hồi quy phiên/làm mới/xung đột bất đồng bộ
  widget_test.dart                           Kiểm tra màn hình nhỏ và xác thực
```

## Chiều phụ thuộc

Bootstrap tạo và sở hữu CustomerSessionController dùng trên toàn ứng dụng. Các màn hình nhận controller một cách tường minh; chúng không tự tạo client, gọi HTTP hay truy cập lưu trữ bảo mật. ChangeNotifier này quản lý danh tính/trạng thái phiên, bảo đảm tài khoản thuộc nhóm Customer và thực hiện các thao tác xác thực/phiên. Nó gọi các lớp trừu tượng truyền tải và lưu trữ trong core. Trạng thái phiên thuộc cấp ứng dụng vì trang chủ, tài khoản, xác thực và điều hướng đều sử dụng nó; không chức năng nào import lớp giao diện của chức năng bên cạnh. Không tạo cặp controller/repository chỉ để chuyển tiếp lời gọi. Màn hình tài khoản nhúng widget xác thực email từ app/session. Core không phụ thuộc vào app, widget, controller hay feature. Theme là dependency giao diện dùng chung ở cấp ứng dụng. Widget dùng chung chỉ phụ thuộc Flutter/theme, không phụ thuộc trạng thái xác thực hay backend.

Trạng thái cục bộ của biểu mẫu (kiểm tra dữ liệu, ẩn mật khẩu, chế độ biểu mẫu được chọn, trạng thái bận/thông báo) nằm trong widget biểu mẫu. Trạng thái phiên toàn ứng dụng nằm trong app/session. Khung ứng dụng quản lý điều hướng và thông báo khi làm mới. Các màn hình trang chủ/tài khoản/đơn hàng là widget nội dung trong vùng hiển thị có giới hạn kích thước và có thể cuộn của khung ứng dụng; chúng không tạo khung điều hướng lồng nhau. Bốn chế độ xác thực được giữ trong cùng một màn hình biểu mẫu vì dùng chung trường nhập và quy tắc kiểm tra; hiện chúng chưa phải bốn route độc lập.

## An toàn phiên và quyền sở hữu tài nguyên

Controller phiên giữ cơ chế chỉ có một yêu cầu làm mới token cho mỗi thế hệ phiên, ghi lưu trữ bảo mật tuần tự, kiểm tra mốc phiên để loại bỏ yêu cầu đến muộn và thu hồi refresh token mới nhất sau khi xoay vòng khi đăng xuất. Kết quả làm mới từ phiên cũ không thể khôi phục phiên đã xóa hoặc ghi đè lần đăng nhập mới. Khóa lưu trữ vẫn là `customer_session`. Hợp đồng HTTP và thông báo tiếng Việt cho người dùng được giữ nguyên. Bootstrap sở hữu và giải phóng controller cùng HTTP client của nó. Kiểm thử sở hữu các controller mà chúng truyền vào. Có thể truyền MockClient và TokenStore khi kiểm thử.

Dữ liệu JSON danh tính thô hiện tuân theo hợp đồng backend sẵn có. Khi mở rộng hợp đồng, bổ sung model danh tính có kiểu dữ liệu và cập nhật đồng bộ các nơi sử dụng controller. Lớp domain sẽ phù hợp khi có quy tắc đặt chuyến thực tế; các thư mục model, use-case, datasource và service rỗng hiện chưa mang lại giá trị.

## Phần dùng chung

Trong ứng dụng này, `core` chia sẻ hạ tầng, `shared` chia sẻ UI/kiểm tra dữ liệu tổng quát và `app` chia sẻ theme/lắp ghép dependency/điều hướng. Thẻ dịch vụ chỉ thuộc trang chủ; xác thực email thuộc app/session vì tài khoản và xác thực cùng sử dụng hành vi phiên. Không đặt màn hình hoặc repository riêng của chức năng vào `shared`.

Ứng dụng khách hàng và tài xế vẫn là các repository riêng, không import tương đối sang nhau. Hai ứng dụng có thể theo cùng quy ước, nhưng quy tắc tài khoản Customer, khóa lưu token và điều hướng thuộc riêng ứng dụng này. Nếu hạ tầng trùng lặp đã ổn định và cần tách thành package, hãy phát hành package Dart riêng tư có quản lý phiên bản (hoặc dependency Git có phiên bản riêng); giữ phần điều phối xác thực và chức năng khách hàng/tài xế trong repository tương ứng. Không tạo dependency ngầm vào một bản checkout bên cạnh.

## Thêm màn hình

1. Thêm màn hình vào `features/<feature>/presentation/screens/` và thành phần cục bộ vào `widgets/` của chức năng đó.
2. Với tương tác UI cục bộ, sử dụng trạng thái widget. Với trạng thái bất đồng bộ dùng chung, thêm controller được truyền vào trong `presentation/controllers/`.
3. Đặt thao tác API/ánh xạ trạng thái của chức năng trong repository `data/` khi cần, tái sử dụng phần truyền tải/lưu trữ của core. Vòng đời danh tính/phiên thuộc app/session. Chỉ thêm model khi nó mô tả một hợp đồng thực tế.
4. Lắp ghép dependency trong bootstrap và kết nối điều hướng qua khung ứng dụng; tránh lấy service từ biến toàn cục hoặc import main.dart.
5. Chỉ chuyển widget sang shared khi các chức năng không liên quan cần dùng nó. Giữ quan hệ phụ thuộc của chức năng tường minh.
6. Thêm kiểm thử hồi quy hành vi, sau đó chạy `flutter analyze`, `flutter test` và `flutter build web`.

Việc tái cấu trúc này không bổ sung tìm chuyến, đặt chuyến, thanh toán, tải ảnh đại diện hoặc chỉnh sửa hồ sơ: khả năng của backend vẫn như trước. Build APK/iOS native và các luồng backend/email thực tế cần được xác minh riêng.
