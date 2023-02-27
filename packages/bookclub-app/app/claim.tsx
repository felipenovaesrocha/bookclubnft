import Image from "next/image";
import { Inter } from "next/font/google";
// import styles from './page.module.css'

const inter = Inter({ subsets: ["latin"] });

export default function Home() {
  return (
    <main className={"h-screen flex items-center justify-center"}>
      <div className={"mx-auto"}>
        <p className="text-3xl font-bold underline">
          Pege seu NFT do seu livro predileto!&nbsp;
        </p>
        <div></div>
      </div>
    </main>
  );
}
