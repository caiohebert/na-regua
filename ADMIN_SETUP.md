# Configuração de Perfil Admin

## Problema: Dashboard Carregando Infinitamente

Se o Admin Dashboard fica carregando infinitamente, significa que seu usuário **não tem um perfil de barbeiro associado** na tabela `barbers`.

## Solução Rápida

### Passo 1: Configurar seu Usuário como ADMIN

1. Acesse o [Supabase Dashboard](https://supabase.com/dashboard/project/gubjgwuwskflxzzkkdlp)
2. Vá para **Table Editor** → **users**
3. Encontre seu usuário (pelo email)
4. Edite o registro e defina:
   - `type` = `ADMIN` (MAIÚSCULAS)
5. Clique em **Save**

### Passo 2: Criar um Perfil de Barbeiro

Todo admin precisa ter um perfil correspondente na tabela `barbers`:

1. No Supabase, vá para **Table Editor** → **barbers**
2. Clique em **Insert** → **Insert row**
3. Preencha os campos:
   ```
   id: (gerado automaticamente)
   user_id: <COLE O ID DO SEU USUÁRIO>
   name: Seu Nome
   image_url: (opcional) URL da sua foto
   rating: 5.0 (opcional)
   location: Seu local (opcional)
   created_at: (gerado automaticamente)
   ```
4. Clique em **Save**

#### Como encontrar seu `user_id`:

1. Na tabela **users**, encontre seu usuário
2. Copie o valor da coluna `id` (UUID)
3. Cole esse valor no campo `user_id` da tabela `barbers`

### Passo 3: Criar Time Slots (Horários Disponíveis)

Para aceitar agendamentos, você precisa criar time slots:

1. Vá para **SQL Editor** no Supabase
2. Execute este script para criar horários para a próxima semana:

```sql
-- Substitua 'SEU_BARBER_ID' pelo ID do barber que você criou
-- Substitua 'YYYY-MM-DD' pela data desejada

INSERT INTO time_slots (barber_id, date, time, status)
VALUES
  ('SEU_BARBER_ID', 'YYYY-MM-DD', '09:00', 'AVAILABLE'),
  ('SEU_BARBER_ID', 'YYYY-MM-DD', '10:00', 'AVAILABLE'),
  ('SEU_BARBER_ID', 'YYYY-MM-DD', '11:00', 'AVAILABLE'),
  ('SEU_BARBER_ID', 'YYYY-MM-DD', '14:00', 'AVAILABLE'),
  ('SEU_BARBER_ID', 'YYYY-MM-DD', '15:00', 'AVAILABLE'),
  ('SEU_BARBER_ID', 'YYYY-MM-DD', '16:00', 'AVAILABLE');
```

### Passo 4: Verificar Permissões RLS

Certifique-se de que as permissões RLS estão configuradas corretamente:

```sql
-- Permitir que admins vejam todos os appointments
CREATE POLICY "Admins can view all appointments"
ON appointments FOR SELECT
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM barbers
    WHERE barbers.id = appointments.barber_id
    AND barbers.user_id = auth.uid()
  )
);

-- Permitir que admins vejam seu próprio perfil de barber
CREATE POLICY "Users can view their barber profile"
ON barbers FOR SELECT
TO authenticated
USING (user_id = auth.uid());
```

## Verificação

Após seguir os passos acima:

1. **Recarregue** seu app (hot reload ou restart)
2. **Faça login** novamente
3. O Admin Dashboard deve carregar corretamente

## Estrutura das Tabelas

### Tabela `users`
```
id: UUID (PK)
email: TEXT
name: TEXT
type: VARCHAR ('CUSTOMER' ou 'ADMIN')
```

### Tabela `barbers`
```
id: UUID (PK)
user_id: UUID (FK → users.id)
name: TEXT
image_url: TEXT (opcional)
rating: FLOAT (opcional)
location: TEXT (opcional)
```

### Tabela `time_slots`
```
id: UUID (PK)
barber_id: UUID (FK → barbers.id)
date: DATE
time: TIME
status: VARCHAR ('AVAILABLE' ou 'BOOKED')
```

## Troubleshooting

### Dashboard ainda carregando infinitamente?

1. Abra o **Console do navegador** (F12)
2. Veja se há erros em vermelho
3. Clique em **"Ver Detalhes"** na tela de erro do dashboard
4. Verifique as mensagens de debug no console

### Erro: "No barber profile found"

- Certifique-se de que existe um registro na tabela `barbers` com o `user_id` igual ao ID do seu usuário

### Erro: "Policy violation" ou "Permission denied"

- Verifique as políticas RLS no Supabase
- Execute os scripts de permissão acima

### Ainda com problemas?

Verifique os logs de debug:
- O código agora imprime mensagens úteis no console
- Procure por mensagens começando com: "Fetching barber profile...", "No barber profile found", etc.

## Script Completo de Configuração

Execute este script SQL para configurar tudo de uma vez (substitua os valores):

```sql
-- 1. Atualizar usuário para ADMIN
UPDATE users 
SET type = 'ADMIN' 
WHERE email = 'seu-email@exemplo.com';

-- 2. Criar perfil de barbeiro
INSERT INTO barbers (user_id, name, rating, location)
SELECT id, name, 5.0, 'Sua localização'
FROM users 
WHERE email = 'seu-email@exemplo.com';

-- 3. Criar time slots para os próximos 7 dias
DO $$
DECLARE
  barber_uuid UUID;
  current_date DATE := CURRENT_DATE;
  day_offset INT;
BEGIN
  -- Pegar o ID do barber recém-criado
  SELECT b.id INTO barber_uuid
  FROM barbers b
  INNER JOIN users u ON b.user_id = u.id
  WHERE u.email = 'seu-email@exemplo.com';

  -- Criar slots para os próximos 7 dias
  FOR day_offset IN 0..6 LOOP
    INSERT INTO time_slots (barber_id, date, time, status)
    VALUES
      (barber_uuid, current_date + day_offset, '09:00', 'AVAILABLE'),
      (barber_uuid, current_date + day_offset, '10:00', 'AVAILABLE'),
      (barber_uuid, current_date + day_offset, '11:00', 'AVAILABLE'),
      (barber_uuid, current_date + day_offset, '14:00', 'AVAILABLE'),
      (barber_uuid, current_date + day_offset, '15:00', 'AVAILABLE'),
      (barber_uuid, current_date + day_offset, '16:00', 'AVAILABLE'),
      (barber_uuid, current_date + day_offset, '17:00', 'AVAILABLE');
  END LOOP;
END $$;
```

Não esqueça de substituir `'seu-email@exemplo.com'` pelo seu email real!


