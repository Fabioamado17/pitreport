# Sistema de Notificações por Email — PitReport

Este documento explica como implementar o envio de emails automáticos para notificar os utilizadores quando o estado das suas denúncias é alterado pelo administrador.

---

## Arquitetura

```
Admin altera estado (SPA)
    → escreve documento em Firestore "mail"
        → Firebase Extension deteta o documento
            → envia email via SMTP (SendGrid / Gmail / etc.)
                → utilizador recebe notificação
```

Não é necessário servidor próprio nem Cloud Functions — a extensão oficial do Firebase trata de tudo.

---

## Passo 1 — Criar conta de envio SMTP

Escolhe um dos seguintes fornecedores:

### Opção A — SendGrid (recomendado)

1. Criar conta gratuita em https://sendgrid.com (100 emails/dia grátis)
2. Ir a **Settings → API Keys → Create API Key** (permissão "Mail Send")
3. Guardar a API key gerada (só é mostrada uma vez)
4. A URI SMTP fica: `smtps://apikey:<API_KEY>@smtp.sendgrid.net:465`

### Opção B — Gmail (apenas para testes)

1. Ativar verificação em dois passos na conta Google
2. Ir a **Conta Google → Segurança → Palavras-passe de aplicação**
3. Gerar uma palavra-passe para "Correio"
4. A URI SMTP fica: `smtps://<EMAIL>:<APP_PASSWORD>@smtp.gmail.com:465`

> **Nota:** O Gmail tem limite de ~500 emails/dia e pode bloquear envios em produção. Usar apenas para desenvolvimento.

---

## Passo 2 — Instalar a extensão no Firebase Console

1. Ir ao **Firebase Console** → projeto `pit-report`
2. No menu lateral: **Build → Extensions**
3. Pesquisar **"Trigger Email from Firestore"**
4. Clicar em **Install** e seguir o assistente:

| Campo | Valor |
|---|---|
| Cloud Functions location | `europe-west1` (mesma região do projeto) |
| SMTP connection URI | URI do passo 1 (ex: `smtps://apikey:SG.xxx@smtp.sendgrid.net:465`) |
| Email documents collection | `mail` |
| Default FROM address | `noreply@pit-report.firebaseapp.com` (ou domínio próprio) |
| Default FROM name | `PitReport` |
| Users collection | `users` (opcional — para resolver emails por UID) |

5. Clicar em **Install extension** e aguardar (2-3 minutos)

---

## Passo 3 — Atualizar as regras do Firestore

Adicionar a regra para a coleção `mail` nas **Firestore Security Rules**:

```
match /mail/{docId} {
  // Apenas admins podem criar emails
  allow create: if isAdmin();
  // Ninguém lê ou altera documentos de mail (a extensão usa o Admin SDK)
  allow read, update, delete: if false;
}
```

---

## Passo 4 — Criar o serviço no SPA

Criar o ficheiro `src/services/mail.ts`:

```ts
import { addDoc, collection } from "firebase/firestore";
import { db } from "../firebase";

const STATUS_LABELS: Record<string, string> = {
  pending: "Pendente",
  in_progress: "Em progresso",
  resolved: "Resolvido",
};

export async function sendStatusEmail(
  to: string,
  reportTitle: string,
  newStatus: string
): Promise<void> {
  await addDoc(collection(db, "mail"), {
    to,
    message: {
      subject: `PitReport — Atualização da tua denúncia`,
      html: `
        <div style="font-family:sans-serif;max-width:520px;margin:0 auto">
          <div style="background:#151929;padding:24px 32px;border-radius:8px 8px 0 0">
            <span style="color:#fff;font-size:20px;font-weight:bold">Pit</span>
            <span style="color:#F5A623;font-size:20px;font-weight:bold">Report</span>
          </div>
          <div style="background:#f9fafb;padding:32px;border-radius:0 0 8px 8px;border:1px solid #e5e7eb">
            <p style="margin:0 0 16px;color:#374151">
              O estado da tua denúncia foi atualizado:
            </p>
            <p style="margin:0 0 8px;font-weight:600;color:#151929;font-size:16px">
              ${reportTitle}
            </p>
            <p style="margin:0 0 24px">
              Novo estado:
              <strong style="color:#F5A623">${STATUS_LABELS[newStatus] ?? newStatus}</strong>
            </p>
            <p style="margin:0;color:#9ca3af;font-size:13px">
              Podes consultar os detalhes na aplicação PitReport.
            </p>
          </div>
        </div>
      `,
    },
  });
}
```

---

## Passo 5 — Integrar na página de detalhe da denúncia

No ficheiro `src/pages/ReportDetailPage.tsx`, é necessário:

### 5a. Importar o serviço e buscar o email do utilizador

```ts
import { sendStatusEmail } from "../services/mail";
import { doc, getDoc } from "firebase/firestore"; // já importado
```

Adicionar uma função que obtém o email do utilizador pelo UID:

```ts
async function getUserEmail(userId: string): Promise<string | null> {
  const snap = await getDoc(doc(db, "users", userId));
  if (!snap.exists()) return null;
  return (snap.data().email as string) ?? null;
}
```

### 5b. Adicionar estado para controlar o envio de email

```ts
const [sendEmail, setSendEmail] = useState(true); // checkbox no formulário
```

### 5c. Atualizar a função handleSave

```ts
async function handleSave() {
  if (!report) return;
  setSaving(true);
  await updateReportStatus(report.id, status);

  if (sendEmail) {
    const email = await getUserEmail(report.userId);
    if (email) {
      await sendStatusEmail(email, report.title, status);
    }
  }

  setReport((prev) => prev ? { ...prev, status } : prev);
  setSaving(false);
  setSaved(true);
  setTimeout(() => setSaved(false), 2000);
}
```

### 5d. Adicionar checkbox no painel lateral (junto ao botão Guardar)

```tsx
<label className="flex items-center gap-2 text-sm text-gray-600 cursor-pointer">
  <input
    type="checkbox"
    checked={sendEmail}
    onChange={(e) => setSendEmail(e.target.checked)}
    className="rounded border-gray-300 text-orange focus:ring-orange"
  />
  Notificar utilizador por email
</label>
```

---

## Como verificar se está a funcionar

Após guardar um estado com a opção de email ativa:

1. Ir ao **Firebase Console → Firestore → coleção `mail`**
2. O documento criado deve ter o campo `delivery.state`:
   - `PROCESSING` — a extensão está a enviar
   - `SUCCESS` — email enviado com sucesso
   - `ERROR` — falhou (ver `delivery.error` para o motivo)

---

## Casos de uso possíveis (extensões futuras)

| Evento | Trigger | Destinatário |
|---|---|---|
| Estado alterado | Admin guarda novo estado | Utilizador da denúncia |
| Nova denúncia submetida | App Flutter cria report | Admin (email fixo) |
| Resposta de feedback | Admin envia mensagem | Utilizador da denúncia |
| Denúncia resolvida | Estado → resolved | Utilizador da denúncia |

Para notificar o admin por nova denúncia, a app Flutter pode escrever diretamente na coleção `mail` após criar o report (requer atualizar as Firestore Security Rules para permitir `create` em `mail` a utilizadores autenticados).

---

## Estrutura completa de um documento `mail`

```json
{
  "to": "utilizador@email.com",
  "cc": "copia@email.com",
  "bcc": "registo@email.com",
  "message": {
    "subject": "Assunto do email",
    "text": "Versão em texto simples (fallback)",
    "html": "<p>Versão HTML</p>"
  }
}
```

A extensão também suporta templates Handlebars se configurada com a opção **"Firestore templates collection"**, permitindo reutilizar designs de email sem alterar código.
