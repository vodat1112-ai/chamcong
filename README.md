# Hệ thống chấm công nhân công

Đăng nhập bằng số điện thoại, ghi nội dung công việc mỗi ngày, xin nghỉ phép, xuất bảng chấm công Excel. Tài khoản admin theo dõi và xuất Excel toàn bộ nhân công.

## Bước 1. Tạo backend miễn phí (Supabase)
1. Vào https://supabase.com, đăng ký và bấm **New project**.
2. Vào **SQL Editor > New query**, dán toàn bộ `setup.sql`, bấm **Run**.
   (Nếu đã chạy bản cũ, làm theo ghi chú ở đầu `setup.sql` để xoá bảng cũ trước.)
3. Vào **Authentication > Providers > Email**: **tắt** "Confirm email" (bắt buộc, vì công nhân đăng ký bằng số điện thoại, không có email thật).
4. Vào **Project Settings > API**, copy **Project URL** và khoá **anon public**.
5. Mở `index.html`, dán vào `SUPABASE_URL` và `SUPABASE_ANON_KEY`.
   Khoá anon được phép công khai, dữ liệu được bảo vệ bằng quy tắc trong `setup.sql`. Không dùng khoá `service_role`.

## Bước 2. Đưa lên GitHub Pages
1. Tạo repository mới trên GitHub, ví dụ `cham-cong`.
2. Tải `index.html` lên (**Add file > Upload files**).
3. Vào **Settings > Pages**, chọn **Deploy from a branch**, nhánh `main`, thư mục `/ (root)`, bấm **Save**.
4. Sau 1 đến 2 phút, trang chạy tại `https://TEN-CUA-BAN.github.io/cham-cong/`. Gửi link này cho công nhân.

## Bước 3. Tạo tài khoản admin
1. Mở trang, bấm **Tạo tài khoản mới**, đăng ký bằng số điện thoại của bạn và đặt tên.
2. Trong Supabase SQL Editor chạy (thay số điện thoại):
   `update public.profiles set role = 'admin' where phone = '0901234567';`
3. Đăng nhập lại: sẽ thấy tab **Quản lý**.

## Cách dùng
- **Nhân công**: đăng ký số điện thoại và mật khẩu, đặt tên ở lần đầu. Mỗi ngày nhập nội dung công việc, bấm **Vào ca**, cuối ngày bấm **Ra ca**. Có thể đăng ký nghỉ phép cho ngày bất kỳ và xuất Excel theo tháng.
- **Admin**: chọn tháng, xem tổng hợp từng người, bấm **Chi tiết** để xem bảng cả tháng, xuất Excel từng người hoặc tất cả (1 sheet tổng hợp và mỗi người 1 sheet).

## Lưu ý
- **Quên mật khẩu**: hệ thống chưa gửi được tin nhắn. Admin đặt lại trong Supabase: **Authentication > Users > chọn người dùng > Send/Reset password** hoặc xoá và tạo lại tài khoản.
- Nếu đăng ký báo "email invalid", đổi `EMAIL_DOMAIN` ở đầu `index.html` sang tên miền khác.
- Chỉ chấm công được cho ngày hôm nay (giờ Việt Nam); nghỉ phép đăng ký được cho ngày bất kỳ.
- Giờ vào/ra lấy từ đồng hồ điện thoại nên có thể bị chỉnh giờ máy.
