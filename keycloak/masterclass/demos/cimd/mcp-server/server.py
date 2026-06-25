import os

from fastmcp import FastMCP
from fastmcp.server.auth import require_scopes
from fastmcp.server.auth.providers.keycloak import KeycloakAuthProvider

KEYCLOAK_URL = os.getenv("KEYCLOAK_URL", "http://localhost:8080")
REALM = os.getenv("KEYCLOAK_REALM", "mcp-demo")
MCP_SERVER_URL = os.getenv("MCP_SERVER_URL", "http://localhost:8000")

auth = KeycloakAuthProvider(
    realm_url=f"{KEYCLOAK_URL}/realms/{REALM}",
    base_url=MCP_SERVER_URL,
)

mcp = FastMCP(
    name="CIMD Demo MCP Server",
    auth=auth,
)


@mcp.tool(auth=require_scopes("mcp:tools"))
def get_greeting(name: str) -> str:
    """Return a personalized greeting."""
    return f"Hello, {name}! You are authenticated via Keycloak CIMD."


@mcp.tool(auth=require_scopes("mcp:tools"))
def list_demo_topics() -> list[str]:
    """List the topics covered in this Keycloak masterclass demo."""
    return [
        "Client ID Metadata Document (CIMD)",
        "OAuth 2.1 Authorization Code + PKCE",
        "Protected Resource Metadata (RFC 9728)",
        "Authorization Server Metadata (RFC 8414)",
        "Keycloak as Authorization Server",
        "FastMCP as Resource Server",
    ]


@mcp.tool(auth=require_scopes("mcp:tools"))
def explain_cimd() -> dict:
    """Explain what CIMD is and how it works in this demo."""
    return {
        "what": "Client ID Metadata Document — the client_id is a URL, not a string.",
        "how": "The authorization server fetches the URL to learn about the client.",
        "claude_code_cimd_url": "https://claude.ai/oauth/claude-code-client-metadata",
        "flow": [
            "1. Claude Code connects to MCP server",
            "2. MCP server returns 401 with WWW-Authenticate pointing to its resource metadata",
            "3. Claude Code fetches /.well-known/oauth-protected-resource",
            "4. Claude Code discovers Keycloak as authorization server",
            "5. Claude Code sends auth request with client_id=https://claude.ai/oauth/claude-code-client-metadata",
            "6. Keycloak fetches that URL to validate the client",
            "7. User logs in, gets redirected back with auth code",
            "8. Claude Code exchanges code for access token",
            "9. Claude Code calls MCP tools with Bearer token",
        ],
    }


if __name__ == "__main__":
    mcp.run(transport="http", host="0.0.0.0", port=8000)
