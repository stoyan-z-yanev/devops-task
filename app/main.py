from fastapi import FastAPI, HTTPException
import asyncpg
import httpx
import os

app = FastAPI()

COINGECKO_URL = "https://api.coingecko.com/api/v3/coins/markets"
COINGECKO_PARAMS = {
    'vs_currency': 'usd',
    'order': 'market_cap_desc',
    'per_page': 100,
    'page': 1,
    'sparkline': 'false'
}
DATABASE_URL = os.getenv("DATABASE_URL")

@app.on_event("startup")
async def startup():
    app.state.pool = await asyncpg.create_pool(DATABASE_URL)

@app.on_event("shutdown")
async def shutdown():
    await app.state.pool.close()

@app.post("/populate")
async def populate_db():
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(COINGECKO_URL, params=COINGECKO_PARAMS)
            response.raise_for_status()
        except httpx.HTTPStatusError as e:
            raise HTTPException(status_code=e.response.status_code, detail=str(e))
        except httpx.RequestError as e:
            raise HTTPException(status_code=500, detail="Error while requesting data")

    data = response.json()

    async with app.state.pool.acquire() as connection:
        async with connection.transaction():
            for item in data:
                await connection.execute("""
                    INSERT INTO crypto_data (name, symbol, price)
                    VALUES ($1, $2, $3)
                """, item['name'], item['symbol'], item['current_price'])

    return {"status": "Database populated successfully"}

@app.delete("/delete")
async def delete_data():
    async with app.state.pool.acquire() as connection:
        await connection.execute("DELETE FROM crypto_data")
    
    return {"status": "Data deleted successfully"}
