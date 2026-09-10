# NiniXray — پنل ۳x-ui واقعی روی Railway
۳x-ui (Xray-core) با داشبورد واقعی: CPU / RAM / ترافیک / کاربر آنلاین + پروتکل‌های VLESS، VMess، Trojan، Shadowsocks.

## دیپلوی یک‌کلیک
روی دکمه زیر کلیک کن (به حساب Railway خودت وصل می‌شه):

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy?template=https://github.com/YOUR_USERNAME/ninixray)

یا دستی:
1. ریپو را Fork کن
2. Railway → New Project → Deploy from GitHub repo
3. متغیرهای محیطی (اختیاری): `PANEL_USER`، `PANEL_PASS`، `PANEL_PATH` (پیش‌فرض: reza4343 / reza4343 / n)
4. Railway پورت را خودکار می‌دهد (۲۰۵۳ داخلی)؛ دامنه‌ی عمومی را باز کن → `/n/` پنل است

## ورود
- آدرس: `https://<your-app>.up.railway.app/n/`
- کاربر: `reza4343` | رمز: `reza4343` (در تنظیمات عوض کن)

## نکته
Railway فقط HTTPS رو بیرون می‌دهد؛ ۳x-ui روی پورت ۲۰۵۳ داخلی اجرا می‌شه و ترافیک پروکسی از طریق WebSocket (مسیر /n یا مسیر دلخواه) رد می‌شه — در کلاینت (v2rayNG) نوع را **ws** بزن.


<!-- deploy trigger 00:05 -->