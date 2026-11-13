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
        
        // Expose this directly to the model instead of only through Code Mode.
        options: { codemode: false },

        execute: async (input, context) => {
          const { title } = input as { title: string }
          
          await ctx.permission.assert({
            sessionID: context.sessionID,
            agent: context.agent,
            source: { type: "tool", messageID: context.messageID, id: context.id },
            action: "archive_arxiv",
            resources: [title],
          })

          const output = await new Promise<string>((resolve) => {
              execFile(
                  PYTHON,
                  [ARCHIVE_TOOL, "--title", title],
                  {
                      timeout: 240_000,
                      signal: context.signal,
                  },
                  (error, stdout, stderr) => {
                      const receipt = String(stdout ?? "").trim()

                      // archive_tool.py prints its receipt even when it exits 1.
                      if (receipt) {
                          resolve(receipt)
                          return
                      }

                      if (error) {
                          resolve(
                              JSON.stringify({
                                  status: "failed",
                                  error: {
                                      type: "execution_error",
                                      message: String(stderr ?? "").trim() || error.message,
                                  },
                              }),
                          )
                          return
                      }

                      resolve(
                          JSON.stringify({
                              status: "failed",
                              error: {
                                  type: "invalid_tool_output",
                                  message: "Archive tool returned no output"
                              },
                          }),
                      )
                  },
              )
          })

          return { content: output }
        },
      })
    })
  },
})
