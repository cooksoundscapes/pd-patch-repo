# Pd Patch Repo

Atoms, macros, instruments, UIs and Lua scripts for general use

# Module Params
DIvided by 4 encoders X 8 seq. buttons with (or without) a shift button:

IDEIAS BOASS:
* Shift pode ser o 4o nav_button
* Assign por ser o 5o nav_button, oq ele faz:
    * segura e mexe num controle: assign o exp.pedal pra ele
    * OU: segura e aperta os seq buttons de 1 a 4 pra mesma coisa
    * segunda opção é interessante por que:
        * segurar e mexer nos enc. 1 e 2 podem ajustar o clamping (max e min do pedal)
    * pensar num atalho pra INVERTER

basic mapping:
```
1:{
    oneoffs.master,
    oneoffs.od-gain,
    mod-01-mix / mod-lfo.rate,
    pitchshift.t1 / pitchshift.t2
},
2: {
    amp-lfo.bpm / amp-lfo.bpm.div,
    amp-lfo.depth,
    amp-lfo.wave,
    oneoffs.degrade / oneoffs.bitcrush
},
3: {
    delay.level,
    delay.fdbk / delay.mod.depth (mod.rate fixed),
    delay.bpm / delay.bpm.div,
    delay.lop / delay.hip,
},
4: {
    glitch.chance,
    glitch.length,
    glitch.bpm / glitch.bpm.div,
    glitch.dry
},
5: {
    gt-synth.cutoff / gt-synth.Q,
    gt-synth.waveform / gt-synth.osc-2,
    gt-synth.pitch-1 / gt-synth.pitch-2,
    gt-synth.pitch.lfo.cents / gt-synth.pitch.lfo.rate,
},
6: {
    gt-synth.cutoff-key,
    gt-synth.filter.lfo.depth,
    gt-synth.filter.lfo.rate
    gt-synth.filter.lfo.wave / gt-synth.pitch.lfo.wave
}
```

---

# Organização dos Controles do Projeto

## 1️⃣ Seq Buttons (1–8)

- **1–6:** Selecionam bancos.
- **7–8:** Futuramente podem ser usados para mais bancos ou funções especiais.
- Ao pressionar:
  - Atualiza `current_bank`.
  - Dispara o **preset handler** para enviar os parâmetros e valores atuais daquele banco.

---

## 2️⃣ Nav Buttons (6 totais, por enquanto usamos 4 e 5)

| Nav | Função atual |
|-----|-------------|
| 4   | **Shift** |
| 5   | **Assign** |
| 1–3, 6 | Não usados ainda |

### Shift (nav4)
- Enquanto pressionado:
  - Se um parâmetro tiver `/` (dois subparâmetros), **os encoders alteram o segundo parâmetro**.
  - Usado para acessar layer alternativo / parâmetros extras do banco.

### Assign (nav5)
- Segurar + seq button 1–8:
  - 1–4 → parâmetros normais
  - 5–8 → parâmetros do shift
  - Ação: **assignar pedal de expressão** para aquele parâmetro.
- Segurar + enc1 / enc2:
  - Ajusta **clamping do pedal** (max e min).
- Status interno: `assign_active = true` enquanto pressionado.
- Segurar `shift + assign + seq<N>`: assimila o pedal de expressão INVERTIDO praquele parâmetro.

---

## 3️⃣ Encoders (4 por banco)

- Sempre alteram os parâmetros mapeados no banco atual.
- Com **shift ativo**, afetam o subparâmetro `/` se houver.
- Com **assign ativo**, podem servir para clamping do pedal (dependendo da combinação de seq/nav buttons).

---

## 4️⃣ Regras de Prioridade / Interação

1. **Shift > Encoder:** shift modifica a função do encoder.
2. **Assign > Seq:** assign + seq define pedal assignment.
3. **Assign + Encoder1/2:** define clamping do pedal.
4. Valores de parâmetro são sempre **controlados pelo preset handler**, HUD apenas reflete depois.

---

## 5️⃣ Estrutura Mental do Preset Handler

```text
preset_handler
├─ current_bank
├─ shift_active
├─ assign_active
├─ encoders[4] → controlam parâmetros do banco atual
├─ seq_buttons[8] → trocam banco ou interagem com assign
├─ nav_buttons[6] → flags shift / assign
├─ parametros por banco[6] → cada um tem até 4 parâmetros, com possíveis / para layer extra
└─ função handle_input(button/encoder)
    ├─ atualiza banco ou flags
    ├─ atualiza parâmetros via encoder
    └─ envia status e valores atuais para consumidores (HUD, MIDI, OSC, etc)
```

## 6️⃣ Observações Importantes

- O **preset handler** é o centro de verdade — ele sabe os valores atuais, clamping, assignments, etc.
- O **console HUD** ou qualquer outro módulo só recebe dados do handler; não precisa entender a lógica de shift/assign/encoders.
- Mantendo essas regras centralizadas, fica fácil adicionar:
  - Novos bancos
  - Mais nav buttons
  - Funcionalidades extras (invert, macros, etc)
- Atualizações são **event-driven**, não contínuas; ocorrem apenas quando o usuário muda de banco ou parâmetros.
