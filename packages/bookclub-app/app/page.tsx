import Image from "next/image";
import { Inter } from "next/font/google";
// import styles from './page.module.css'

const inter = Inter({ subsets: ["latin"] });

export default function Home() {
  return (
    <main className={"h-screen flex items-center justify-center"}>
      <div className={"mx-auto"}>
        <p className="text-3xl font-bold underline">
          Get started by editing&nbsp;
          <code className={""}>app/page.tsx</code>
        </p>
        <div>
          <a
            href="https://vercel.com?utm_source=create-next-app&utm_medium=appdir-template&utm_campaign=create-next-app"
            target="_blank"
            rel="noopener noreferrer"
          >
            By{" "}
          </a>
        </div>
      </div>
    </main>
  );
}
