from __future__ import annotations

import uvicorn

from auto_money_doc.api.server import app


if __name__ == "__main__":
    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8765,
        reload=False,
    )
