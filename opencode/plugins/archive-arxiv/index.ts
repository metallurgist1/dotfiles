import { execFile } from "node:child_process"
import { Plugin } from "@opencode/plugin"

const PYTHON = "/usr/bin/python3"
const ARCHIVE_TOOL = "/Users/bob/projects/personal_sandbox/local_runtime/archive_tool.py"

export default Plugin.define({
  id: "archive-arxiv",
  async setup(ctx) {
    await ctx.tool.transform((editor) => {
      editor.add({
        name: "archive_arxiv",
        description: "Archive and verify a public arXiv paper by exact title.",
        input: {
          type: "object",
          properties: {
            title: {
              type: "string",
              description: "The exact public arXiv paper title.",
            },
          },
          required: ["title"],
          additionalProperties: false,
        },
        execute: async (input, context) => {
          const { title } = input as { title: string }
          await ctx.permission.assert({
            sessionID: context.sessionID,
            agent: context.agent,
            source: { type: "tool", messageID: context.messageID, id: context.id },
            action: "archive_arxiv",
            resources: [title],
          })
          const stdout = await new Promise<string>((resolve, reject) => {
            execFile(
              PYTHON,
              [ARCHIVE_TOOL, "--title", title],
              { timeout: 240_000, signal: context.signal },
              (error, out, _stderr) => {
                // archive_tool.py prints a JSON receipt even when it exits with an error
                resolve(String(out ?? ""))
              },
            )
          })
          return { content: stdout.trim() || '{"status":"failed","error":{"type":"no_output"}}' }
        },
      })
    })
  },
})
