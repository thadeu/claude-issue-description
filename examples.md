# trello — examples

## Postmortem (production bug)

```markdown
## Postmortem — Loop no cadastro de usuário

**O que aconteceu**
Novos usuários que pagavam o primeiro boleto, mas ainda não tinham cadastrado um atendente, ficavam presos em um loop infinito de redirecionamento entre duas telas do onboarding.

**Por quê**
Duas regras do sistema se contradiziam: uma tela exigia que o pagamento fosse "reconhecido" antes de continuar; outra exigia que o atendente existisse antes de mostrar a tela de reconhecimento. O sistema nunca marcava o pagamento como reconhecido.

**Impacto**
Usuários afetados não conseguiam concluir o cadastro após o primeiro pagamento.

**Como resolvemos**
1. **Imediato:** ajuste manual no banco para marcar o pagamento como reconhecido no usuário afetado.
2. **Definitivo:** correção no código para permitir a tela de reconhecimento mesmo sem atendente cadastrado.

**Prevenção**
Deploy da correção em produção para evitar que novos cadastros caiam no mesmo cenário.
```

## Slack (ultra-short)

```markdown
**Resumo:** Cadastro travava em loop após primeiro boleto pago sem atendente cadastrado.

**Causa:** Duas telas de onboarding se redirecionavam mutuamente e o pagamento nunca era marcado como reconhecido.

**Fix:** Hotfix no banco no usuário afetado + PR que libera a tela de reconhecimento sem exigir atendente.

**Status:** Resolvido no usuário; deploy do fix definitivo pendente.
```

## Deploy note (no incident)

```markdown
## Deploy — Reconhecimento de primeiro pagamento no onboarding

**O que mudou**
Usuários com primeiro pagamento confirmado agora conseguem ver a tela de reconhecimento antes de cadastrar um atendente.

**Por quê**
O fluxo anterior gerava loop para contas novas com boleto pago e sem atendente.

**Impacto**
Apenas melhoria de fluxo; sem mudança de regra de negócio.

**Status**
Pronto para deploy após merge.
```
