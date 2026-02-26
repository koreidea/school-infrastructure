"""Supabase database client."""

import os
from supabase import create_client, Client

_client: Client | None = None


def get_db() -> Client:
    global _client
    if _client is None:
        url = os.environ.get("SUPABASE_URL", "https://yiihjrxfupuohxzubusv.supabase.co")
        key = os.environ.get("SUPABASE_SERVICE_KEY", os.environ.get("SUPABASE_KEY", ""))
        _client = create_client(url, key)
    return _client
