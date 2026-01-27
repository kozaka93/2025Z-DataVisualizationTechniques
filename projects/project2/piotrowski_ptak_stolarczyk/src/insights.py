import pandas as pd

def generate_insights(df, max_sentences: int = 6):
    insights = []

    if df.empty:
        return ["No data available to generate insights."]

    days = df['date'].nunique() if 'date' in df.columns else len(df)
    if 'steps' in df.columns:
        avg_steps = df['steps'].mean()
        insights.append(f"Across {days} days, average steps are **{avg_steps:,.0f}**.")
    if 'total_screen_hours' in df.columns:
        avg_screen = df['total_screen_hours'].mean()
        insights.append(f"Average daily screen time is **{avg_screen:.1f}h**.")
    if 'balance_index' in df.columns:
        avg_balance = df['balance_index'].mean()
        insights.append(f"Your mean Balance Index is **{avg_balance:.1f}/100**.")

    if 'rain_flag' in df.columns and 'steps' in df.columns:
        avg_rain = df[df['rain_flag'] == True]['steps'].mean()
        avg_dry = df[df['rain_flag'] == False]['steps'].mean()
        if pd.notna(avg_rain) and pd.notna(avg_dry) and avg_dry > 0:
            diff_pct = ((avg_rain - avg_dry) / avg_dry) * 100
            insights.append(
                f"Rainy days show **{diff_pct:.1f}%** change in steps "
                f"(**{avg_rain:,.0f}** vs **{avg_dry:,.0f}**)."
            )

    if 'has_classes' in df.columns and 'steps' in df.columns:
        avg_class = df[df['has_classes'] == True]['steps'].mean()
        avg_free = df[df['has_classes'] == False]['steps'].mean()
        if pd.notna(avg_class) and pd.notna(avg_free):
            insights.append(
                f"Class days average **{avg_class:,.0f}** steps vs **{avg_free:,.0f}** on free days."
            )

    corr_cols = [
        c for c in [
            'steps', 'total_screen_hours', 'digital_load', 'balance_index',
            'class_hours', 'temp_mean_c', 'precip_mm', 'distance_km'
        ] if c in df.columns
    ]
    if len(corr_cols) >= 2:
        corr = df[corr_cols].corr()
        corr = corr.where(~pd.isna(corr))
        corr_values = corr.unstack().dropna()
        corr_values = corr_values[corr_values.index.get_level_values(0) != corr_values.index.get_level_values(1)]
        if not corr_values.empty:
            top_pair = corr_values.abs().sort_values(ascending=False).head(1)
            (a, b), val = top_pair.index[0], corr_values.loc[top_pair.index[0]]
            insights.append(f"Strongest correlation is between **{a}** and **{b}** (r = **{val:.2f}**).")

    while len(insights) < 3:
        insights.append("More data will unlock deeper comparisons across routines and weather.")
    return insights[:max_sentences]
