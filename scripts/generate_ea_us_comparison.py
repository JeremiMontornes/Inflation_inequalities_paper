from pathlib import Path
import pandas as pd
ROOT = Path(__file__).resolve().parents[1]
F = ROOT / "fig"
u = pd.read_csv(F / "us_income_quintile_chained_cpi.csv")
u["date"] = pd.to_datetime(u.ym.astype(str), format="%Y%m")
u = u.rename(columns={"income_quintile":"q"})
e = pd.read_csv(F / "ea20_income_long_comparison_input.csv", parse_dates=["date"])
e["q"] = e.category.map({"First quintile":1,"Fifth quintile":5})
series = {}
for region,df in [("Euro area",e),("United States",u)]:
 for q in [1,5]:
  x=df.loc[df.q.eq(q)].set_index("date").price_index.sort_index()
  assert x.index.is_unique and x.notna().all() and (x>0).all()
  series[(region,q)] = x
end = min(x.index.max() for x in series.values())
rows=[]
for base in [pd.Timestamp("2002-01-01"),pd.Timestamp("2021-01-01")]:
 for (region,q),x in series.items():
  assert base in x.index
  z=x.loc[base:end]/x.loc[base]*100
  assert z.index.equals(pd.date_range(base,end,freq="MS"))
  assert abs(z.iloc[0]-100)<1e-9
  rows.extend({"region":region,"quintile":q,"base":base.strftime("%Y-%m"),"date":d.strftime("%Y-%m-%d"),"index":v} for d,v in z.items())
a=pd.DataFrame(rows);a.to_csv(F/"ea_us_income_comparison_rebased.csv",index=False)
print("Common endpoint:",end.date());print(a[a.date.eq(end.strftime("%Y-%m-%d"))].to_string(index=False))
