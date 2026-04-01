import {
  addDoc,
  collection,
  onSnapshot,
  orderBy,
  query,
  serverTimestamp,
} from "firebase/firestore";
import { db } from "../firebase";
import type { Message } from "../types";

export function subscribeMessages(
  reportId: string,
  callback: (messages: Message[]) => void
): () => void {
  const q = query(
    collection(db, "reports", reportId, "messages"),
    orderBy("createdAt", "asc")
  );
  return onSnapshot(q, (snap) => {
    callback(
      snap.docs.map((d) => {
        const data = d.data();
        return {
          id: d.id,
          text: (data.text as string) ?? "",
          authorName: (data.authorName as string) ?? "Admin",
          authorId: (data.authorId as string) ?? "",
          createdAt:
            (data.createdAt as { toDate?: () => Date })?.toDate?.() ??
            new Date(),
        };
      })
    );
  });
}

export async function sendMessage(
  reportId: string,
  text: string,
  authorId: string,
  authorName: string
): Promise<void> {
  await addDoc(collection(db, "reports", reportId, "messages"), {
    text: text.trim(),
    authorId,
    authorName,
    createdAt: serverTimestamp(),
  });
}
