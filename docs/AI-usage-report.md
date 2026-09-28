# รายงานการใช้ AI ในการพัฒนา PlantOps

## เครื่องมือที่ใช้

- ChatGPT/Codex สำหรับช่วยวิเคราะห์ข้อกำหนด อธิบายขั้นตอน และช่วยพัฒนาโปรแกรม

## งานที่ AI ช่วย

- แยก requirement จากเอกสารงานเป็นหน้าจอ Machine, Alarm, Maintenance, Dashboard, Authentication และส่วนส่งงาน
- ช่วยวางโครงสร้างฐานข้อมูล Supabase, foreign keys, constraints, Row Level Security (RLS) และ SQL สำหรับ grants
- ช่วยตรวจ RLS ที่เดิมเปิดให้ผู้ใช้ Technician แก้ Alarm ได้ทุกฟิลด์ แล้วสร้าง migration ที่จำกัดให้แก้ได้เฉพาะสถานะ และจัด Role Policy ให้ตรงกับขอบเขตงาน
- ช่วยสร้างและปรับปรุง UI ด้วย Next.js, React, TypeScript และ Tailwind CSS
- ช่วยเชื่อม Supabase Auth และการอ่าน/บันทึก/แก้ไขข้อมูลตาม Role
- ช่วยเพิ่มการค้นหา ตัวกรองสถานะและวันที่ การตรวจข้อมูลก่อนบันทึก และ Dashboard ที่คำนวณจากรายการจริง
- ช่วยตรวจรายการประเมินและเติมหน้า Settings, Dark Mode ที่จำค่าบนเบราว์เซอร์, Machine History, CSV Export และการแก้ไข Alarm
- ช่วยจัดทำ README และ GitHub Actions workflow สำหรับ build
- ช่วยอธิบายการตั้งค่า GitHub, Vercel และ Supabase ให้ผู้พัฒนาทำตาม

## งานที่ผู้พัฒนาทำ

- สร้าง Supabase project และรัน SQL ใน SQL Editor
- สมัครบัญชีและกำหนด Role Admin ใน Supabase
- สร้าง GitHub repository และเชื่อม Vercel
- กำหนด environment variables ใน Vercel โดยไม่ใส่ไฟล์ `.env.local` ใน GitHub
- ตรวจว่าเว็บไซต์ที่ Deploy เปิดได้และเข้าสู่ระบบได้

## การตรวจและข้อจำกัด

- ระบบเก็บข้อมูลจริงผ่าน Supabase เมื่อกำหนด URL และ Publishable key; หากไม่กำหนดจะใช้ข้อมูลตัวอย่างใน browser
- GitHub Actions ตั้งให้ติดตั้ง dependencies และ build ทุกครั้งที่ push หรือเปิด pull request ไปยัง `main`
- ตรวจ production build ด้วย `npm run build`, TypeScript ด้วย `npm run lint`, GitHub Actions และสถานะ Production Deployment หลังแก้ไข
- ตรวจ Supabase project จริงว่ามี profiles 2 รายการ, machines 5 รายการ, alarms 4 รายการ, maintenance_records 3 รายการ และตรวจ Policy/trigger สำหรับ Role ด้วย SQL read-only queries
- ยังไม่ได้ทดสอบการแก้ไขข้อมูลผ่านหน้าเว็บด้วยบัญชี Admin และ Technician แยกกัน จึงควรทดลอง CRUD ตาม Role ในการตรวจรับครั้งสุดท้าย
- AI อาจสร้างข้อผิดพลาดหรือคำแนะนำที่ไม่เหมาะกับการใช้งานจริง จึงควรตรวจผลลัพธ์ สิทธิ์ RLS และการตั้งค่า Secret ก่อนนำไปใช้งาน

รายงานนี้เปิดเผยการใช้ AI ตามข้อกำหนดของงาน โดย AI เป็นผู้ช่วยพัฒนาและอธิบาย ส่วนการสร้างบริการภายนอกและการตั้งค่าบัญชีทำโดยผู้พัฒนา
