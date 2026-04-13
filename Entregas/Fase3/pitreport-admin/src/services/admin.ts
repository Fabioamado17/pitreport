import { doc, getDoc } from "firebase/firestore";
import { db } from "../firebase";

/**
 * Verifica se o utilizador com o UID fornecido existe na coleção `admins`.
 * Para adicionar um admin: criar um documento em Firestore > admins > <uid>
 * com o campo { email: "..." } para facilitar identificação.
 */
export async function checkIsAdmin(uid: string): Promise<boolean> {
  const snap = await getDoc(doc(db, "admins", uid));
  return snap.exists();
}
