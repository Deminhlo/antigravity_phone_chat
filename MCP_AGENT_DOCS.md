# Antigravity Phone Connect - MCP Agent Integration Guide

This document is intended for AI Agents (like those running on Node.js/Cursor/Cline) connecting to the Antigravity Phone Connect MCP Server.

## 🔌 Connection Setup

The Antigravity Phone Connect exposes a standard Model Context Protocol (MCP) Server using Server-Sent Events (SSE).

**Endpoints:**
- **SSE Connection URL:** `http://127.0.0.1:3001/mcp/sse`
- **Message POST URL:** `http://127.0.0.1:3001/mcp/message`

*Note: Port 3001 is the default Node server port, this might vary depending on configuration.*

To connect using the official `@modelcontextprotocol/sdk`:

```javascript
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { SSEClientTransport } from '@modelcontextprotocol/sdk/client/sse.js';

// Ignore self-signed certs if running over local HTTPS
process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0'; 

const url = new URL("http://127.0.0.1:3001/mcp/sse");
const transport = new SSEClientTransport(url);
const client = new Client({ name: "YourAgentName", version: "1.0.0" });

await client.connect(transport);
// You are now connected and can call tools!
```

## 🛠️ Available MCP Tools

The Antigravity MCP Server exposes the following tools to control the IDE autonomously:

### 1. `antigravity_list_instances`
Provides a list of all currently open Antigravity IDE windows (projects).
*   **Parameters:** None
*   **Returns:** JSON array of available instances with `title`, `id`, and `webSocketDebuggerUrl`.

### 2. `antigravity_switch_instance`
Redirects the MCP Server's control to a specific Antigravity window.
*   **Parameters:**
    *   `webSocketDebuggerUrl` (string): The URL obtained from `antigravity_list_instances`.
*   **Returns:** Success or failure message.

### 3. `antigravity_get_snapshot`
Fetches the current HTML DOM snapshot of the active Antigravity chat window.
*   **Parameters:** None
*   **Returns:** HTML string representing the current state of the chat, input box, and review UI.

### 4. `antigravity_send_message`
Simulates typing a prompt into the chat input box and clicking submit.
*   **Parameters:**
    *   `message` (string): The prompt or instructions to send to the IDE agent.
*   **Returns:** Success or failure message.

### 5. `antigravity_click_element`
Triggers a click event on any element in the Antigravity UI using typical web selectors. Useful to 'Accept' or 'Reject' code diffs.
*   **Parameters:**
    *   `selector` (string): Standard CSS Selector (e.g., `button.monaco-button`, `.accept-all-btn`).
    *   `index` (number): The 0-based index of the target element amongst all elements matching the selector.
    *   `textContent` (string, optional): Text content to further narrow down the button (e.g., "Accept All").
*   **Returns:** Success or failure message.

### 6. `antigravity_read_chat_history`
Extracts the recent conversation history titles from the IDE's history sidebar.
*   **Parameters:** None
*   **Returns:** JSON formatted string containing the historical chat titles.

## 💡 Best Practices for Agents

1. **Auto-Accepting Changes:** Use `antigravity_get_snapshot` to parse the DOM and see if an "Accept All" button is present. Calculate its exact `selector` and `index`, then use `antigravity_click_element` to click it.
2. **Context Switching:** Always start by checking `antigravity_list_instances` if you expect multiple projects to be open, and use `antigravity_switch_instance` to lock onto the correct project.
3. **Polling vs Webhooks:** The MCP server currently does not push state changes to the MCP client (though it does for the mobile phone client over standard WebSockets). You should periodically poll using `antigravity_get_snapshot` to understand when an IDE generation finishes.
