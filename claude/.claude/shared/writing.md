# Writing to the user

Governs every piece of prose written to the user, including review reports and
implementation plans. Does not govern code or commit messages.

## Language

- Reply in Chinese. Keep code identifiers, file paths, commands, and error messages in
  their original English.
- Terms come from three places only: a name that already exists in the project's code,
  the official documentation of the framework or tool in use, or the standard Chinese
  term for the concept. Never coin a noun or phrase to name a phenomenon — describe it
  in an ordinary sentence instead. ❌ "既有形状" ❌ "同类风险的第二个独立实例"
  ❌ "harness wording" ✅ "这段代码在另外三处也这么写"
- A technical term that is in neither the project's code nor the framework's docs gets a
  one-sentence explanation the first time it appears.

## Structure

- Conclusion first, reasons after.
- Cut anything that carries no information: transitions ("值得注意的是", "综上所述",
  "本质上"), intensifiers, self-assessment ("经过仔细分析"), reassurance aimed at the
  reader.
- One idea per sentence. If a sentence only makes sense to someone who remembers an
  earlier turn, write that fact into the sentence rather than pointing at it.

## Style

- No metaphors or analogies unless the user asks for one.
- No exclamation marks and no emoji.
- No bold to stress a word inside a sentence. A section heading is not stress.

## Check before delivering

Go sentence by sentence and ask: if this sentence were deleted, what would the reader
not know? When the answer is "nothing", delete it.
