# รายงานการใช้ AI ในการพัฒนา PlantOps

## เครื่องมือที่ใช้

- ChatGPT/Codex สำหรับช่วยวิเคราะห์ข้อกำหนด อธิบายขั้นตอน และช่วยพัฒนาโปรแกรม

## งานที่ AI ช่วย

- แยก requirement จากเอกสารงานเป็นหน้าจอ Machine, Alarm, Maintenance, Dashboard, Authentication และส่วนส่งงาน
- ช่วยวางโครงสร้างฐานข้อมูล Supabase, foreign keys, constraints, Row Level Security (RLS) และ SQL สำหรับ grants
- ช่วยสร้างและปรับปรุง UI ด้วย Next.js, React, TypeScript และ Tailwind CSS
- ช่วยเชื่อม Supabase Auth และการอ่าน/บันทึก/แก้ไขข้อมูลตาม Role
- ช่วยเพิ่มการค้นหา ตัวกรองสถานะและวันที่ การตรวจข้อมูลก่อนบันทึก และ Dashboard ที่คำนวณจากรายการจริง
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
- ผู้พัฒนาควรทดสอบการเพิ่ม/แก้ไข Machine, Alarm และ Maintenance ด้วยบัญชี Admin และ Technician รวมถึงค้นหา/กรองข้อมูล ก่อนส่งงาน
- AI อาจสร้างข้อผิดพลาดหรือคำแนะนำที่ไม่เหมาะกับการใช้งานจริง จึงควรตรวจผลลัพธ์ สิทธิ์ RLS และการตั้งค่า Secret ก่อนนำไปใช้งาน

รายงานนี้เปิดเผยการใช้ AI ตามข้อกำหนดของงาน โดย AI เป็นผู้ช่วยพัฒนาและอธิบาย ส่วนการสร้างบริการภายนอกและการตั้งค่าบัญชีทำโดยผู้พัฒนา
