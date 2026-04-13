import { collection, deleteDoc, doc, onSnapshot, updateDoc } from "firebase/firestore";
import { db } from "../firebase";
import type { AppUser } from "../types";

export async function deleteUserDoc(uid: string): Promise<void> {
  await deleteDoc(doc(db, "users", uid));
}

export async function unblockUser(uid: string): Promise<void> {
  await updateDoc(doc(db, "users", uid), { blocked: false, loginAttempts: 0 });
}

export function subscribeAllUsers(
  callback: (users: AppUser[]) => void
): () => void {
  return onSnapshot(collection(db, "users"), (snap) => {
    const users: AppUser[] = snap.docs.map((d) => {
      const data = d.data();
      return {
        id: d.id,
        name: (data.name as string) ?? "",
        email: (data.email as string) ?? "",
        createdAt:
          (data.createdAt as { toDate?: () => Date })?.toDate?.() ?? new Date(0),
        blocked: (data.blocked as boolean) ?? false,
        loginAttempts: (data.loginAttempts as number) ?? 0,
      };
    });
    // Ordenar em memória para não excluir documentos sem createdAt
    users.sort((a, b) => b.createdAt.getTime() - a.createdAt.getTime());
    callback(users);
  });
}
