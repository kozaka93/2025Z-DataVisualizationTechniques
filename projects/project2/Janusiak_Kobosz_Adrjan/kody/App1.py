import os, json, numpy as np, pandas as pd, dash
import plotly.express as px, plotly.graph_objs as go, dash_bootstrap_components as dbc
from dash import Input, Output, State, dcc, html, ALL, MATCH, ctx
from hashlib import md5
from colorsys import hsv_to_rgb
#region Start
COLOURS = {'muzyka': "#13ba31", 
           'studia': "#d72b2b", 
           'komunikatory' : "#5a47ee",
           'gry komputerowe': "#8102a4",
           'oglądanie filmów': "#F7D83B",
           'inne': "#9ca5a8",
           'system': "#5A4E67",
           'przeglądarka': '#6accea',
           'sen': "#423A6E",
           'weekend': '#1e624c'
}
DAYS = {
    0: "Poniedziałek",
    1: "Wtorek",
    2: "Środa",
    3: "Czwartek",
    4: "Piątek",
    5: "Sobota",
    6: "Niedziela",
}
def get_colour(text: str) -> str:
    if text in COLOURS.keys():
        return COLOURS[text]
    else:
        h = int(md5(text.encode("utf-8")).hexdigest(), 16)
        return "rgb(%d,%d,%d)" % tuple([int(i*255) for i in hsv_to_rgb(((h >> 10)%360)/360, 0.7+(0.3*(((h >> 20)%360)/360)), 0.8+(0.2*(((h >> 30)%360)/360)))])

prefix = "/home/appuser/app" if not os.path.exists('./Dane Dash') else "."

app = dash.Dash(
    __name__,
    external_stylesheets=[
        dbc.themes.BOOTSTRAP, #Wygląd
        "https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css",
        "/assets/01_style.css"
    ],
    suppress_callback_exceptions=True,
    title="Dashboard TWD (grupa 8)"
)
DATA_FOLDER = f'{prefix}/Dane Dash/' #Folder do zczytania gotowych danych
DATA_CACHED = f'{prefix}/Dane Dash Fastboot/'
if not os.listdir(DATA_CACHED):
    frames = []  
    for filename in os.listdir(DATA_FOLDER):
        if filename.endswith('.json'):
            filepath = os.path.join(DATA_FOLDER, filename)
            frames.append(pd.read_json(filepath))
    df = pd.concat(frames, ignore_index=True)
    df.to_feather(DATA_CACHED + 'dane.feather')
else:
    df = pd.read_feather(f"{prefix}/Dane Dash Fastboot/dane.feather")
OSOBY = df['osoba'].drop_duplicates().reset_index(drop=True) 
# Kolumny czasowe
timestamp = df['timestamp']
timestamp_pl = timestamp.dt.tz_convert('Europe/Warsaw')
df['timestamp_pl'] = timestamp_pl
df['day_of_year'] = timestamp_pl.dt.day_of_year
df['weekday'] = timestamp_pl.dt.weekday.map(DAYS)
df['weekday_number'] = timestamp_pl.dt.weekday
df['date'] = timestamp_pl.dt.date
df['localized_time_pl'] = df['timestamp_pl'].dt.tz_localize(None)
#endregion
#region --- 1. FUNKCJE POMOCNICZE ---
def create_button_content(label, main_icon, is_open):
    # do przycisków w content_timeline
    """Tworzy zawartość przycisku: Ikona główna + Tekst + Szewron"""
    chevron_icon = "bi-chevron-up" if is_open else "bi-chevron-down"
    return [
        html.I(className=f"bi {main_icon} me-2"), # Główna ikona (po lewej)
        label,
        html.I(className=f"bi {chevron_icon} ms-2 small") # Szewron (po prawej)
    ]
def process_uploaded_file(): #Placeholder od plików
    return
# --- DEFINICJA ZAWARTOŚCI FILTRÓW (OFFCANVAS) ---
def get_week_options(df_in):
    """
    Zwraca listę słowników {'label': '...', 'value': 'YYYY-MM-DD'}
    reprezentującą wszystkie poniedziałki rozpoczynające tygodnie w danych.
    """
    if df_in.empty:
        return []
    
    # Kopiujemy daty
    temp_df = df_in[['timestamp']].copy()
    temp_df['timestamp'] = pd.to_datetime(temp_df['timestamp'])
    
    # Znajdujemy poniedziałek dla każdego rekordu
    # (Data - numer dnia tygodnia)
    temp_df['week_start'] = temp_df['timestamp'].dt.normalize() - \
                            pd.to_timedelta(temp_df['timestamp'].dt.weekday, unit='D')
    
    # Pobieramy unikalne poniedziałki i sortujemy malejąco (najnowsze na górze)
    unique_weeks = temp_df['week_start'].unique()
    unique_weeks = sorted(unique_weeks, reverse=True) # Najnowsze pierwsze
    
    options = []
    for week_start_np in unique_weeks:
        week_start = pd.Timestamp(week_start_np)
        week_end = week_start + pd.Timedelta(days=6)
        
        # Etykieta: "2023-10-16 -> 2023-10-22 (Tydzień 42)"
        label = f"{week_start.strftime('%d.%m')} - {week_end.strftime('%d.%m.%Y')} (Tydz. {week_start.isocalendar()[1]})"
        
        options.append({'label': label, 'value': week_start.strftime('%Y-%m-%d')})
        
    return options
def get_base_panel_style(left_pos="0px"):
    return {
        "top": HEADER_HEIGHT,
        "height": "fit-content",
        "maxHeight": f"calc(100vh - {HEADER_HEIGHT} - 20px)",
        "width": PANEL_WIDTH,
        "left": left_pos,
        
        "position": "fixed", 
        "border": "1px solid #dee2e6",
        "borderTop": "0", "borderLeft": "0",
        "borderRadius": "0 0 10px 10px",
        "boxShadow": "0px 10px 20px rgba(0,0,0,0.15)",
        "zIndex": 1045, # Pod paskiem menu
        
        "transition": "left 0.3s ease-in-out, transform 0.3s ease-in-out" 
    }
def create_global_filters_layout():
    return html.Div([
        # --- SEKCJA 1: CZAS ---
        html.H6("📅 Ustawienia Czasu", className="fw-bold text-primary mb-3"),
        
        dbc.Row([
            # Daty
            dbc.Col([
                html.Label("Zakres dat:", className="small text-muted fw-bold"),
                dcc.DatePickerRange(
                    id='watcher-date-picker',
                    min_date_allowed=None, max_date_allowed=None,
                    start_date=pd.Timestamp(year=2025, month=12, day=14),
                    end_date=df['timestamp'].max().date() if not df.empty else None,
                    display_format='YYYY-MM-DD',
                    style={'width': '100%', 'fontSize': '0.8rem'}
                ),
            ], width=12, className="mb-3"),

            dbc.Col([
                html.Label("Tryb pracy:", className="small text-muted fw-bold mb-1"),
                dbc.RadioItems(
                    id="afk-mode-selector",
                    options=[
                        {
                            "label": html.Div([html.I(className="bi bi-circle-half me-2"), "Wszystko"]), 
                            "value": "all"
                        },
                        {
                            "label": html.Div([html.I(className="bi bi-person-check-fill me-2"), "Aktywność"]), 
                            "value": "active_only"
                        },
                        {
                            "label": html.Div([html.I(className="bi bi-robot me-2"), "AFK"]), 
                            "value": "afk_only"
                        },
                    ],
                    value="active_only",
                    className="btn-group w-100",     # w-100 rozciąga grupę na całą szerokość
                    inputClassName="btn-check",      # Ukrywa kropki radia
                    labelClassName="btn btn-outline-primary", # Styl guzików
                    labelCheckedClassName="active"     # Styl aktywnego guzika
                )
            ], width=12, className="mb-3"),

            # Min czas
            dbc.Col([
                html.Label("Ignoruj krótsze niż (min):", className="small text-muted fw-bold"),
                dbc.Input(id='min-duration-input', type='number', value=0, min=0, step=1, size="sm")
            ], width=12),
        ]),

        html.Hr(className="my-4"), # Linia oddzielająca

        # --- SEKCJA 2: UŻYTKOWNICY ---
        html.H6("👤 Użytkownicy i Urządzenia", className="fw-bold text-primary mb-3"),
        
        html.Div(create_filter_chips(df), id='user-device-filters-container')
    ], className="p-1")
def create_smart_slot(side, title, is_app_mode=False):

    unique_users = sorted(df['osoba'].astype(str).unique())
    
    scope_options = [
        {'label': '👥 PORÓWNANIE (Ranking)', 'value': 'comparison'},
        {'label': '--- Użytkownicy ---', 'value': 'disabled', 'disabled': True}
    ] + [{'label': f"👤 {u}", 'value': u} for u in unique_users]

    # Kontrolki w nagłówku
    controls = []

    scope_dd = dcc.Dropdown(
        id=f'smart-{side}-scope',
        options=scope_options,
        value='comparison', # Domyślnie tryb porównania
        clearable=False, searchable=False,
        style={'fontSize': '0.85rem'}
    )
    controls.append(dbc.Col(scope_dd, width=4))

    if is_app_mode:
        limit_input = dbc.InputGroup([
            dbc.InputGroupText("Top:", style={'fontSize': '0.7rem', 'padding': '4px'}),
            dbc.Input(
                id=f'smart-{side}-limit',
                type='number',
                value=10, min=1, max=50, step=1,
                style={'fontSize': '0.8rem', 'textAlign': 'center'}
            )
        ], size="sm")
        controls.append(dbc.Col(limit_input, width=3))

    # C. WYBÓR RODZAJU WYKRESU (Opcje puste na start, wypełni je Callback UI)
    type_dd = dcc.Dropdown(
        id=f'smart-{side}-type',
        options=[], # Callback to wypełni
        value='bar_h',
        clearable=False, searchable=False,
        style={'fontSize': '0.85rem'}
    )
    # Dopasowanie szerokości w zależności czy jest Top N
    width_type = 4 if is_app_mode else 7 
    controls.append(dbc.Col(type_dd, width=width_type))

    # 3. Złożenie całości
    return dbc.Col(
        dbc.Card([
            dbc.CardBody([
                # Nagłówek z tytułem
                html.H6(title, className="card-title mb-2 text-muted fw-bold"),
                # Pasek narzędzi
                dbc.Row(controls, className="g-1 mb-3 align-items-center"),
                # Wykres
                dcc.Graph(id=f'smart-{side}-chart', config={'displayModeBar': False}, style={'height': '350px'})
            ])
        ], className="shadow-sm h-100"),
        width=12, md=6, className="mb-4"
    )
def get_data_summary():
    summary_list = []
    if not os.path.exists(DATA_FOLDER):
        return pd.DataFrame()
    if os.path.exists(DATA_CACHED +'summary.feather'):
        return pd.read_feather(DATA_CACHED +'summary.feather')
    for filename in os.listdir(DATA_FOLDER):
        if filename.endswith('.json'):
            filepath = os.path.join(DATA_FOLDER, filename)
            try:
                with open(filepath, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                if isinstance(data, list) and len(data) > 0:
                    first_record = data[0]
                    summary_list.append({
                        'Osoba': first_record.get('osoba', 'N/A'),
                        'Plik': filename,
                        'Data Od': str(min([pd.to_datetime(i["timestamp"], format="ISO8601", utc=True) for i in data]).strftime("%d.%m.%Y %H:%M:%S")),
                        'Data Do': str(max([pd.to_datetime(i["timestamp"], format="ISO8601", utc=True) for i in data]).strftime("%d.%m.%Y %H:%M:%S")),
                        'Liczba rekordów': len(data),
                        'Urządzenie': first_record.get('device', 'N/A')
                    })
            except Exception as e:
                print(e)
    summary_list=pd.DataFrame(summary_list)       
    summary_list.to_feather(DATA_CACHED +'summary.feather')
    return summary_list
def create_users_tables_view():
    df = get_data_summary()
    if df.empty:
        return dbc.Alert("Brak plików JSON.", color="warning")
    
    layout_elements = []
    unique_users = sorted(df['Osoba'].unique())
    
    for osoba in unique_users:
        layout_elements.append(
            html.H3(
                [html.I(className="bi bi-person-fill me-2"), f"Użytkownik: {osoba}"], 
                className="mt-4 text-primary"
            )
        )
        person_df = df[df['Osoba'] == osoba].drop(columns=['Osoba'])
        
        table = dbc.Table.from_dataframe(
            person_df, 
            striped=True, 
            bordered=True, 
            hover=True, 
            responsive=True, 
            className="mb-4 shadow-sm",
            style={"width": "auto"} 
        ) 
        layout_elements.append(table)
        layout_elements.append(html.Hr())
        
    return html.Div(layout_elements)

def create_filter_chips(df_in):
    if df_in.empty:
        return html.Div("Brak danych.", className="text-muted")
    
    users = sorted(df_in['osoba'].astype(str).unique())
    detected_devices = sorted(df_in['device'].astype(str).unique())
    icons = {'PC': 'bi-pc-display', 'Laptop': 'bi-laptop', 'Phone': 'bi-phone'}

    rows_list = []
    
    for user in users:
        user_df = df_in[df_in['osoba'] == user]
        buttons = []
        
        # Zbieramy domyślne wartości, żeby zainicjować pamięć
        initial_state = {} 

        for dev in detected_devices:
            has_data = dev in user_df['device'].unique()
            initial_state[dev] = has_data # Zapisujemy startowy stan (True/False)
            
            icon = icons.get(dev, 'bi-hdd')
            
            chk = dbc.Checkbox(
                id={'type': 'device-filter', 'user': user, 'device': dev},
                label=html.Div([html.I(className=f"bi {icon} me-2"), dev]),
                value=has_data,
                disabled=not has_data,
                input_class_name="btn-check", 
                label_class_name=f"btn btn-outline-primary rounded-pill me-2 mb-1 {'disabled opacity-50' if not has_data else ''}"
            )
            buttons.append(chk)
            
        user_row = dbc.Row([
            dbc.Col([
                html.Div([
                    dbc.Switch(
                        id={'type': 'user-master-switch', 'user': user},
                        value=True,
                        label=user,
                        label_class_name="fw-bold text-dark lead",
                        style={"fontSize": "1.1rem"}
                    ),
                    # --- NOWOŚĆ: Pamięć podręczna dla tego konkretnego użytkownika ---
                    dcc.Store(
                        id={'type': 'user-memory', 'user': user},
                        data=initial_state # Na start wpisujemy to, co wynika z danych
                    )
                    # -----------------------------------------------------------------
                ], className="d-flex align-items-center h-100")
            ], width=12, md=3, className="mb-2 mb-md-0"),
            
            dbc.Col(html.Div(buttons, className="d-flex flex-wrap"), width=12, md=9)
        ], className="py-2 border-bottom align-items-center")
        
        rows_list.append(user_row)
        
    return html.Div(rows_list, className="p-2")
def create_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids, get_sleep=False):
    """ Zwraca ramkę danych przefiltrowaną zgodnie z głównym filtrem na górze. 
        Callbacki wykresów będą z tego korzystać. """
     # 1. Sprawdzenie czy są dane
    if df.empty:
        return go.Figure().update_layout(title="Brak wczytanych danych")
    
    # 2. Logika filtrów (Data, Duration, Urządzenia) - BEZ ZMIAN
    s_date = pd.to_datetime(start_date).date() if start_date else df['timestamp'].min().date()
    e_date = pd.to_datetime(end_date).date() if end_date else df['timestamp'].max().date()

    allowed_combinations = set()
    if not filter_values:
        allowed_combinations = set(zip(df['osoba'], df['device']))
    else:
        for val, id_dict in zip(filter_values, filter_ids):
            if val:
                allowed_combinations.add((id_dict['user'], id_dict['device']))

    mask_date = (df['timestamp'].dt.date >= s_date) & (df['timestamp'].dt.date <= e_date)
    min_duration_sec = (min_duration or 0) * 60
    mask_dur = df['duration'] >= min_duration_sec
    mask_dev = df.apply(lambda x: (x['osoba'], x['device']) in allowed_combinations, axis=1) | ((df['osoba'].isin([x[0] for x in allowed_combinations]) & (df['category'] == 'sen')))
    
    filtered_df = df[mask_date & mask_dur & mask_dev].copy()

    # 3. Filtr AFK - BEZ ZMIAN
    if 'status' in filtered_df.columns:
        if afk_mode == 'active_only':
            # szybkie obejście literówki _ -
            filtered_df = filtered_df[(filtered_df['status'].isin(['not-afk','not_afk'])) | (filtered_df['category'] == 'sen')]
        elif afk_mode == 'afk_only':
            filtered_df = filtered_df[(filtered_df['status'] == 'afk') | (filtered_df['category'] == 'sen')]
    # print(filtered_df['status'].value_counts(dropna=False))
    return filtered_df
def create_options_for_weekly_screentime(df_in):
    # 1. Pobieramy listę użytkowników
    unique_users = sorted(df_in['osoba'].astype(str).unique())
    # 2. Budujemy opcje głównego Dropdowna (Scope)
    # Mamy  listę osób
    opcje = [{'label': f"👤 {u}", 'value': u} for u in unique_users]
    osoba_dropdown =  dcc.Dropdown(
    id=f'Wybor-osoby-weekly-time',
    options=opcje,
    value=unique_users[0], # Domyślnie pierwszy z listy
    clearable=False, searchable=False,
    style={'fontSize': '0.85rem'}
    )
    categ_app_dropdown = dcc.Dropdown(
        id = 'Wybor-kateg-weekly-time',
        options=[
            {'label': '📂 Kategorie', 'value': 'category'},
            {'label': '📱 Aplikacje', 'value': 'app'}
        ],
        value='category', # domyślnie pierwsza opcja
        clearable=False,
        searchable=False
    )
    
    topn_col = dbc.Col([
        html.H6('Top N aplikacji', className="card-title mb-2 text-muted fw-bold"),
        dcc.Input(
            id='TopN-app-weekly',
            type='number',
            value=10,
            min=1,
            step=1,
            placeholder='Top N aplikacji',
            style={'width': '100px'}
        )
    ], id='TopN-col', style={'display': 'none'})
    
    dropdowns = dbc.Row([
        dbc.Col([html.H6('Wybierz osobę',className="card-title mb-2 text-muted fw-bold"),osoba_dropdown]),
        dbc.Col([html.H6('Metoda agregacji',className="card-title mb-2 text-muted fw-bold"),categ_app_dropdown]),
        topn_col
    #style={'display': 'flex', 'gap': '10px', 'alignItems': 'center'}
    ])
    return dropdowns
CURRENT_FILTER = [None, None, 0, [], False, []]
FILTERED_DF = df

from threading import Lock
FILTER_LOCK = Lock()


def get_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids):
    global CURRENT_FILTER, FILTERED_DF
    with FILTER_LOCK:
        new_filter = [start_date, end_date, min_duration, filter_values, afk_mode, filter_ids]
        if new_filter != CURRENT_FILTER:
            CURRENT_FILTER = new_filter
            FILTERED_DF = create_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids)
        return FILTERED_DF.copy()
#endregion
#region --- 2. LAYOUTY (STRONY) ---
# STRONA 1 : Użytkownicy /
# Zakłada powitalna , opis skąd są dane co mówią, instrukcja 
content_intro = html.Div([])

content_users = html.Div([
    # html.H1("Panel kontroli danych wejściowych"),
    dbc.Alert("Poniżej znajduje się wykaz wczytanych plików.", color="light"),
    create_users_tables_view()
])
# STRONA 2 : Obserwatorium /watcher
# --- Przygotowanie opcji do Dropdowna (robione raz przy starcie) ---
_unique_users = sorted(df['osoba'].astype(str).unique())
_scope_options = [
    {'label': '👥 PORÓWNANIE (Ranking)', 'value': 'comparison'},
    {'label': '--- Użytkownicy ---', 'value': 'disabled', 'disabled': True}
] + [{'label': f"👤 {u}", 'value': u} for u in _unique_users]

# --- NOWY CONTENT_WATCHER (Układ 2 kolumnowy w 1 rzędzie) ---
content_watcher = html.Div([
    
    # --- RZĄD 1: DWA GŁÓWNE WYKRESY OBOK SIEBIE ---
    dbc.Row([
        
        # KOLUMNA LEWA: Główna Analiza
        dbc.Col([
            dbc.Card([
                dbc.CardHeader("Zgrupowane Dane", className="fw-bold"),
                dbc.CardBody([
                    # RZĄD KONTROLEK
                    dbc.Row([
                        # 1. SCOPE
                        dbc.Col([
                            html.Label("Wybierz osobę", className="small text-muted fw-bold"),
                            dcc.Dropdown(
                                id='watcher-main-scope',
                                options=_scope_options,
                                value='comparison', 
                                clearable=False, searchable=False
                            )
                        ], width=12, md=3),

                        # 2. MODE
                        dbc.Col([
                            html.Label("Metoda agregacji", className="small text-muted fw-bold"),
                            dcc.Dropdown(
                                id='watcher-main-mode',
                                options=[
                                    {'label': '📂 Kategorie', 'value': 'category'},
                                    {'label': '📱 Aplikacje', 'value': 'app'}
                                ],
                                value='category',
                                clearable=False, searchable=False
                            )
                        ], width=12, md=3),

                        # 3. LIMIT
                        dbc.Col([
                            html.Label("Top N kategorii", className="small text-muted fw-bold"),
                            dbc.Input(
                                id='watcher-main-limit',
                                type='number',
                                value=10, min=1, max=50, step=1
                            )
                        ], width=12, md=2),

                        # 4. TYP WYKRESU
                        dbc.Col([
                            html.Label("Typ Wykresu", className="small text-muted fw-bold"),
                            dcc.Dropdown(
                                id='watcher-main-type',
                                options=[], 
                                value='bar_h',
                                clearable=False, searchable=False
                            )
                        ], width=12, md=4),
                    ], className="g-2 mb-3"),

                    # html.Hr(),

                    # WYKRES
                    dcc.Loading(
                        dcc.Graph(id='watcher-main-chart', config={'displayModeBar': False}, style={'height': '400px'}),
                        type="dot", color="#0d6efd"
                    )
                ])
            ], className="shadow-sm h-100") 
        ], width=12, lg=6, className="mb-4"), # POPRAWKA: width=12 (mobile), lg=6 (desktop)

        # KOLUMNA PRAWA: Typowy Tydzień
        dbc.Col([
            dbc.Card([
                # POPRAWKA: Usunięto nadmiarowy nawias [ przed CardHeader
                dbc.CardHeader("Typowy Tydzień", className="fw-bold"),
                dbc.CardBody([
                    create_options_for_weekly_screentime(df), 
                    html.Br(),
                    dcc.Loading(
                        dcc.Graph(id='weekly_hours_plotly', config={'displayModeBar': False}, style={'height': '400px'}),
                        type="dot"
                    )
                ])
            ], className="shadow-sm h-100") 
        ], width=12, lg=6, className="mb-4"), # POPRAWKA: width=12 (mobile), lg=6 (desktop)

    ]), # Koniec Rzędu 1

    # --- RZĄD 2: LINIA CZASU (Na całą szerokość) ---    
    dbc.Card([
        dbc.CardHeader("Dzienna aktywność", className="fw-bold"),
        dbc.CardBody([
            dbc.Row([            
                dbc.Col([
                    html.Label("Zaznacz:", className="me-2 small fw-bold"),
                    dbc.Checklist(
                        options=[
                            {"label": "Weekendy", "value": "weekend"},
                            {"label": "Święta", "value": "holiday"}
                        ],
                        value=["weekend", "holiday"],
                        id="highlight-options",
                        inline=True
                    )
                ])
            ], className="align-items-center mb-2"),
            dcc.Graph(id='activity-line-plot', config={'displayModeBar': False})
        ])
    ], className="shadow-sm mb-4")
])# content_summary= html.Div([
#     html.H1('Typowy tydzień'),
#     dbc.Card(dbc.CardBody([
#         create_options_for_weekly_screentime(df),
#         dcc.Graph(id='weekly_hours_plotly',config={'displayModeBar': False})
#     ]))
# ])
# STRONA 4 : Oś czasu /timeline
content_timeline = html.Div([
    # html.H2("Oś Czasu - Tygodniowy Harmonogram", className="mb-4 display-6 text-primary"),
    
    # 1. PANEL GŁÓWNY (Osoba + Tydzień)
    # ZMIANA: Dodano id='timeline-card-selection'
    dbc.Card(id='timeline-card-selection', children=[
        dbc.CardBody([
            dbc.Row([
                dbc.Col([
                    html.Label("Wybierz Osobę:", className="fw-bold small"),
                    dcc.Dropdown(id='timeline-user-select', placeholder="Wybierz użytkownika...", clearable=False)
                ], width=12, md=4),
                dbc.Col([
                    html.Label("Wybierz Tydzień:", className="fw-bold small"),
                    dcc.Dropdown(id='timeline-week-select', placeholder="Najpierw wybierz osobę...", clearable=False)
                ], width=12, md=8),
            ], className="g-3 align-items-end mb-4"),
            
        ], className="p-4")
    ], className="shadow-sm mb-4"),

    # 2. PANEL ZE SLIDEREM
    # ZMIANA: Dodano id='timeline-card-slider'
    dbc.Card(id='timeline-card-slider', children=[
        html.Div([
                html.Label("🔎 Zakres doby:", className="small text-muted fw-bold mb-3 ms-1"),
                dcc.RangeSlider(
                    id='timeline-slider',
                    min=0, max=24, step=1, value=[0, 24], 
                    marks={i: {'label': f'{i}:00', 'style': {'fontSize': '10px'}} for i in range(0, 25)}, 
                    allowCross=False, pushable=1
                )
            ], className="bg-light bg-opacity-75 rounded-3 p-3")
    ], className="shadow-sm mb-4"),

    # 3. PANEL FILTROWANIA (Fasolki)
    # ZMIANA: Dodano id='timeline-card-filters'
    dbc.Card(id='timeline-card-filters', children=[
        dbc.CardBody([
            dbc.Row(
                    [
                        # 1. MODE SWITCH
                        dbc.Col(
                            dbc.RadioItems(
                                id="timeline-mode-switch",
                                options=[
                                    {"label": "Kategorie", "value": "category"},
                                    {"label": "Aplikacje", "value": "app"},
                                ],
                                value="category",
                                inline=True,
                                className="btn-group",
                                inputClassName="btn-check",
                                labelClassName="btn btn-outline-primary me-0",
                                labelCheckedClassName="active",
                            ),
                            width=12,
                            md=3,
                            className="border-end pe-2",
                        ),

                        # 2. ACTION BUTTONS (OWN COLUMN)
                        dbc.Col(
                            html.Div(
                                [
                                    dbc.Button(
                                        "Zaznacz wszystko",
                                        id="timeline-btn-all",
                                        size="sm",
                                        outline=True,
                                        color="dark",
                                        className="mb-1 w-100",
                                    ),
                                    dbc.Button(
                                        "Odznacz",
                                        id="timeline-btn-none",
                                        size="sm",
                                        outline=True,
                                        color="dark",
                                        className="w-100",
                                    ),
                                ],
                                className="d-flex flex-column",
                            ),
                            width=12,
                            md=1,
                            className="border-end pe-2",
                        ),

                        # 3. FILTER CHECKLIST
                        dbc.Col(
                            dcc.Loading(
                                dbc.Checklist(
                                    id="timeline-top-filter",
                                    options=[],
                                    value=[],
                                    inline=True,
                                    input_class_name="btn-check",
                                    label_class_name="btn btn-outline-secondary rounded-pill mb-1",
                                    label_checked_class_name="active btn-secondary text-white",
                                ),
                                type="dot",
                                color="#6c757d",
                            ),
                            width=12,
                            md=8,
                            className="ps-md-2",
                        ),
                    ],
                    className="align-items-start",
                )
        ], className="py-3")
    ], className="shadow-sm mb-4"),

    # 4. WYKRES (Tego nie chowamy)
    dbc.Card([
        dbc.CardBody([
            dcc.Loading(
                dcc.Graph(id='timeline-graph', style={'height': '800px'}),
                type="dot", color="#0d6efd"
            )
        ])
    ], className="shadow-sm")
])

# endregion
#region --- 3. GŁÓWNA STRUKTURA ---
sidebar = html.Div(
    [
        html.H2("Panele", className="display-6"),
        html.Hr(),
        dbc.Nav([
            dbc.NavLink("O projekcie", href="/", active="exact"),
            dbc.NavLink("Wczytane dane", href="/wczytane", active="exact"),
            dbc.NavLink("Obserwatorium", href="/watcher", active="exact"),
            # dbc.NavLink("Podsumowanie", href="/summary", active="exact"),
            dbc.NavLink("Oś czasu", href="/timeline", active="exact"),
            dbc.NavLink("Sen", href="/sleep", active="exact"),
            # dbc.NavLink("Ustawienia", href="/settings", active="exact"),
            #dbc.NavLink("Załącz pliki", href="/addFile", active="exact"), # raczej do wycofania
        ], vertical=True, pills=True),
    ],
    style={"width": "16rem", "height": "100vh", "background-color": "#f8f9fa", "padding": "2rem 1rem"}
)
# --- STAŁE WYMIARY ---
HEADER_HEIGHT = "70px"
PANEL_WIDTH_NUM = 545      # Szerokość w pikselach (int do obliczeń)
PANEL_WIDTH = f"{PANEL_WIDTH_NUM}px" # String do CSS
filters_panel = dbc.Offcanvas(
    children=[create_global_filters_layout()],
    id="filters-offcanvas",
    title="Filtry Globalne",
    placement="top", scrollable=True, backdrop=False, is_open=False,
    # Styl startowy (zostanie nadpisany przez callback, ale musi być)
    style=get_base_panel_style("16rem") 
)
# Zwiększenie warstwy panel 2
extra_panel_style = get_base_panel_style("16rem")
# Ręcznie podbijamy warstwę (baza ma 1045)
extra_panel_style["zIndex"] = 1060 
extra_panel = dbc.Offcanvas(
    children=[
        html.H6("ale animacja jest", className="fw-bold text-primary mb-3"),        
    ],
    id="extra-offcanvas",
    title="Nie wiem czy tu coś zrobimy",
    placement="top", scrollable=True, backdrop=False, is_open=False,
    style=extra_panel_style
)
app.layout = html.Div([
    dcc.Location(id="url", refresh=False),
    
    # Przechowujemy szerokość sidebara w pamięci przeglądarki (opcjonalnie), 
    # ale tutaj obliczymy to w locie.
    
    dbc.Collapse(sidebar, id="sidebar", is_open=True, dimension="width"),
    
    # DWA PANELE
    filters_panel,
    extra_panel,

    html.Div([
        dbc.Container([
            
            # --- NAGŁÓWEK Z 3 GUZIKAMI ---
            dbc.Row([
                # 1. Menu
                dbc.Col([
                    dbc.Button([html.I(className="bi bi-list me-2"), "Menu"], 
                               id="sidebar-toggle", color="secondary", outline=True, className="me-2"),
                ], width="auto"),
                dbc.Col(
                    html.H4(
                        id="header-title", 
                        children="", 
                        # ZMIANY STYLU:
                        # text-primary -> Niebieski kolor (jak na stronach)
                        # fw-normal -> Zwykła grubość czcionki (bardziej elegancka)
                        # m-0 -> Brak marginesów
                        # ms-2 -> Odstęp od guzików
                        className="m-0 text-primary fw-normal ms-0",
                        style={"letterSpacing": "1px", "fontSize": "3rem"}
                    ),
                    # ZMIANA: width="auto" sprawia, że kolumna jest tylko tak szeroka jak napis
                    width="auto", 
                    className="d-flex align-items-center"
                ),
                # 2. Filtry
                dbc.Col([
                    dbc.Button([html.I(className="bi bi-funnel-fill me-2"), "Filtry"], 
                               id="open-filters-btn", color="primary", className="fw-bold shadow-sm me-2"),
                ], width="auto"),

                # 3. NOWY GUZIK (Opcje)
                # dbc.Col([
                #     dbc.Button([html.I(className="bi bi-gear-fill me-2"), "Opcje"], 
                #                id="open-extra-btn", color="info", className="fw-bold shadow-sm text-white"),
                # ], width="auto"),
                dbc.Col(
                    html.Div(style={
                        "borderLeft": "2px solid #dee2e6", # Jasnoszara linia
                        "height": "24px",                # Wysokość linii (nie za wysoka)
                        "margin": "0 10px"                 # Odstępy po bokach
                    }),
                    width="auto",
                    className="d-flex align-items-center" # Wyśrodkowanie linii w pionie
                ),
                # --- SEKCJA 2: LOKALNA (TUTAJ WSKAKUJĄ GUZIKI) ---
                # Bez tego ID guziki się nie pojawią!
                dbc.Col(
                    id="page-action-container", 
                    children=[], # Domyślnie pusto
                    width="auto",
                    className="d-flex align-items-center"
                ),
                
                # 5. WYPYCHACZ (To on zajmuje resztę miejsca po prawej)
                dbc.Col(width=True)                
            ], 
            className="align-items-center border-bottom px-3",
            style={
                "height": HEADER_HEIGHT, 
                "overflow": "hidden", "position": "sticky", "top": "0", 
                "backgroundColor": "white", "zIndex": 2000
            }),

            html.Div(id="page-content", className="p-4")
            
        ], fluid=True, className="p-0")
    ], style={"flexGrow": 1, "padding": "0", "overflow": "auto", "height": "100vh"})
], className="d-flex")
# --- 4. CALLBACKI ---
#endregion
# region CALLBACKS
# region CALLBACK - PAGE LOADERS
@app.callback(Output("page-content", "children"), Input("url", "pathname"))
def render_page_content(pathname):
    if pathname == "/": 
        return content_intro
    elif pathname == "/wczytane": 
        return content_users
    elif pathname == "/watcher": 
        return content_watcher
    elif pathname == "/timeline": 
        return content_timeline
    elif pathname == "/sleep": 
        return content_sleep
    
    # Obsługa błędu 404
    return dbc.Alert(f"404: Nie znaleziono strony o adresie {pathname}", color="danger")
@app.callback(Output('output-file-upload', 'children'),
              Input('upload-data', 'contents'),
              State('upload-data', 'filename'))
def update_output(list_of_contents, list_of_names):
    if list_of_contents is not None:
        messages = []
        # Iterujemy przez wszystkie wrzucone pliki (obsługa multiple=True)
        for contents, name in zip(list_of_contents, list_of_names):
            # WYWOŁANIE FUNKCJI PLACEHOLDER
            result_msg = process_uploaded_file(name, contents)
            
            # Tworzymy ładny komunikat dla każdego pliku
            messages.append(
                dbc.Alert([
                    html.I(className="bi bi-check-circle-fill me-2"),
                    result_msg
                ], color="success", className="mb-2")
            )
        return messages
    return "" # Pusty string jeśli nic nie wrzucono
@app.callback(Output("header-title", "children"), Input("url", "pathname"))
def update_header_title(pathname):
    if pathname == "/": 
        return "O projekcie"
    elif pathname == "/wczytane": 
        return "Wczytane dane"
    elif pathname == "/watcher": 
        return "Obserwatorium"
    elif pathname == "/summary": 
        return "Podsumowanie"
    elif pathname == "/timeline": 
        return "Oś Czasu"
    elif pathname == "/sleep": 
        return "Sen"
    elif pathname == "/settings": 
        return "Ustawienia"
    elif pathname == "/addFile": 
        return "Import Danych"
    return ""
@app.callback(Output("page-action-container", "children"), Input("url", "pathname"))
def display_timeline_toggle_buttons(pathname):
    if pathname == "/timeline":
        #0096ff #4b83d8
        kolor_guzikow='#4b83d8'
        return [
            # Guzik 1: Wybór Osoby
            dbc.Button(
                create_button_content("Osoba", "bi-person-bounding-box", True),
                id="btn-toggle-selection", 
                style={
                            "backgroundColor": kolor_guzikow,
                            "borderColor": kolor_guzikow,
                            "color": "white"
                        },
                className="shadow-sm text-white me-2 px-4 d-flex align-items-center", 
            ),
            
            # Guzik 2: Suwak Czasu
            dbc.Button(
                create_button_content("Czas", "bi-clock", True),
                id="btn-toggle-slider", 
                style={
                            "backgroundColor": kolor_guzikow,
                            "borderColor": kolor_guzikow,
                            "color": "white"
                        },
                className="shadow-sm text-white me-2 px-4 d-flex align-items-center",
            ),
            
            # Guzik 3: Filtry
            dbc.Button(
                create_button_content("Filtry", "bi-tags", True),
                id="btn-toggle-filters", 
                style={
                            "backgroundColor": kolor_guzikow,
                            "borderColor": kolor_guzikow,
                            "color": "white"
                        },
                className="shadow-sm text-white px-4 d-flex align-items-center",
            )
        ]
    return []

@app.callback(
    [
     # Wyjścia stylów (Karty)
     Output("timeline-card-selection", "style"),
     Output("timeline-card-slider", "style"),
     Output("timeline-card-filters", "style"),
     # Nowe wyjścia treści (Przyciski)
     Output("btn-toggle-selection", "children"),
     Output("btn-toggle-slider", "children"),
     Output("btn-toggle-filters", "children")
    ],
    [Input("btn-toggle-selection", "n_clicks"),
     Input("btn-toggle-slider", "n_clicks"),
     Input("btn-toggle-filters", "n_clicks")],
    [State("timeline-card-selection", "style"),
     State("timeline-card-slider", "style"),
     State("timeline-card-filters", "style")],
    prevent_initial_call=True
)
def toggle_timeline_cards(n1, n2, n3, style1, style2, style3):
    # 1. Inicjalizacja stylów (jeśli są None)
    style1 = style1 or {}
    style2 = style2 or {}
    style3 = style3 or {}

    triggered_id = ctx.triggered_id

    # Funkcja pomocnicza do przełączania display
    def toggle_display(current_style):
        if current_style.get('display') == 'none':
            return {} # Pokaż
        else:
            return {'display': 'none'} # Ukryj

    # 2. Logika zmiany STYLU (tylko dla klikniętego elementu)
    # Warunek 'and nX' zapobiega odpaleniu przy ładowaniu strony
    if triggered_id == "btn-toggle-selection" and n1:
        style1 = toggle_display(style1)
    elif triggered_id == "btn-toggle-slider" and n2:
        style2 = toggle_display(style2)
    elif triggered_id == "btn-toggle-filters" and n3:
        style3 = toggle_display(style3)

    # 3. Logika zmiany IKON (dla WSZYSTKICH przycisków na podstawie nowych stylów)
    # Sprawdzamy czy styl NIE ma 'display: none' -> znaczy że jest otwarte
    is_open1 = style1.get('display') != 'none'
    is_open2 = style2.get('display') != 'none'
    is_open3 = style3.get('display') != 'none'

    # Generujemy nową zawartość guzików
    content1 = create_button_content("Osoba", "bi-person-bounding-box", is_open1)
    content2 = create_button_content("Czas", "bi-clock", is_open2)
    content3 = create_button_content("Kategorie", "bi-tags", is_open3)

    return style1, style2, style3, content1, content2, content3# endregion
# region CALLBACK - WYKRESY
@app.callback(
    [Output('watcher-main-type', 'options'), 
     Output('watcher-main-type', 'value')],
    [Input('watcher-main-scope', 'value')]
)
def update_watcher_chart_options(scope):
    if scope == 'comparison':
        # Dla porównania
        options = [
            {'label': 'Słupkowy poziomy', 'value': 'bar_h'},
            {'label': 'Słupkowy pionowy', 'value': 'bar'}
        ]
        return options, 'bar_h'
    else:
        # Dla pojedynczej osoby
        options = [
            {'label': 'Słupkowy poziomy', 'value': 'bar_h'},
            {'label': 'Słupkowy pionowy', 'value': 'bar'},
            {'label': 'Treemap', 'value': 'treemap'},
            {'label': 'Kołowy', 'value': 'pie'},
            {'label': 'Pierścieniowy', 'value': 'donut'}
        ]
        return options, 'bar_h'

# --- CALLBACK: GENEROWANIE FASOLEK (TOP 10) ---
@app.callback(
    [Output("timeline-top-filter", "options"),
     Output("timeline-top-filter", "value")],
    [
        Input("timeline-mode-switch", "value"),
        Input("timeline-user-select", "value"),
        Input("timeline-week-select", "value"),
        # Globalne
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value')
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')]
)
def update_timeline_filter_options(mode, user, week, s_date, e_date, min_dur, f_vals, afk, f_ids):
    # 1. Pobieramy dane (Globalne filtry)
    df_filtered = get_filtered_df(s_date, e_date, min_dur, f_vals, afk, f_ids)
    if df_filtered.empty or not user or not week:
        return [], []

    # Fix daty
    # NOWOSC, używam polskiego czasu
    # df_filtered['timestamp'] = df_filtered['timestamp_pl']
    # if df_filtered['timestamp'].dt.tz is not None:
    #     df_filtered['timestamp'] = df_filtered['timestamp'].dt.tz_localize(None)
    df_filtered['timestamp'] = df_filtered['localized_time_pl'] # optymalizacja
    # 2. Filtrujemy do konkretnego tygodnia i usera
    week_start = pd.Timestamp(week)
    week_end = week_start + pd.Timedelta(days=7)
    
    df_week = df_filtered[
        (df_filtered['osoba'] == user) & 
        (df_filtered['timestamp'] >= week_start) & 
        (df_filtered['timestamp'] < week_end)
    ]

    if df_week.empty:
        return [], []

    # 3. Agregacja Top 10 wg wybranego trybu
    # Wybieramy kolumnę do grupowania
    col_group = 'category' if mode == 'category' else ('app' if 'app' in df_week.columns else 'category')
    
    # Sumujemy czas
    top_items = df_week.groupby(col_group)['duration'].sum().sort_values(ascending=False).head(10)
    
    # Tworzymy opcje
    options = [{'label': item, 'value': item} for item in top_items.index]
    
    # Domyślnie zaznaczamy wszystko co znaleźliśmy
    initial_value = [opt['value'] for opt in options]
    
    return options, initial_value
# --- CALLBACK: OBSŁUGA GUZIKÓW SELECT ALL / DESELECT ALL ---
@app.callback(
    Output('watcher-main-chart', 'figure'),
    [
        # Globalne Filtry
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value'),
        
        # Lokalne kontrolki (4 inputy)
        Input('watcher-main-scope', 'value'), # 1. Kto
        Input('watcher-main-mode', 'value'),  # 2. Co
        Input('watcher-main-limit', 'value'), # 3. Ile
        Input('watcher-main-type', 'value')   # 4. Jak
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')]
)
def update_main_watcher_chart(start_date, end_date, min_duration, filter_values, afk_mode,
                              scope, mode, limit, chart_type,
                              filter_ids):
    
    # 1. Pobieramy przefiltrowane dane
    filtered_df = get_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids)
    
    if filtered_df.empty:
        return go.Figure().update_layout(title="Brak danych", template='plotly_white')
    
    # Usuwamy sen z analizy ogólnej (zwykle nie chcemy go w tym widoku)
    df_work = filtered_df[filtered_df['category'] != 'sen'].copy()
    if df_work.empty:
        return go.Figure().update_layout(title="Brak danych (po usunięciu snu)", template='plotly_white')

    # 2. Ustalamy kolumnę grupującą (App vs Category)
    # Zabezpieczenie: jeśli wybrano 'app' a nie ma takiej kolumny, wracamy do 'category'
    group_col = 'app' if (mode == 'app' and 'app' in df_work.columns) else 'category'
    label_text = "Aplikacja" if group_col == 'app' else "Kategoria"

    # 3. Filtrowanie po Osobie (Scope)
    title_prefix = ""
    if scope == 'comparison':
        title_prefix = "Ranking Zespołu"
    else:
        df_work = df_work[df_work['osoba'] == scope]
        title_prefix = f"Analiza: {scope}"
        if df_work.empty:
            return go.Figure().update_layout(title=f"Brak danych dla użytkownika: {scope}")

    # 4. Logika Top N (Ograniczamy ilość elementów)
    # Grupujemy po tym, co chcemy pokazać (np. aplikacje) i sumujemy czas
    # Jeśli to porównanie, to chcemy Top N aplikacji OGÓŁEM dla wszystkich, żeby kolory były spójne
    top_items = df_work.groupby(group_col)['duration'].sum().sort_values(ascending=False).head(limit or 10).index
    
    # Zostawiamy w danych tylko te topowe elementy
    df_final = df_work[df_work[group_col].isin(top_items)].copy()

    # 5. Agregacja pod wykres
    if scope == 'comparison':
        # X = Osoba, Kolor = Aplikacja/Kategoria
        agg_df = df_final.groupby(['osoba', group_col])['duration'].sum().reset_index()
        x_axis = 'osoba'
        color_axis = group_col
    else:
        # X = Aplikacja/Kategoria, Kolor = Aplikacja/Kategoria
        agg_df = df_final.groupby(group_col)['duration'].sum().reset_index()
        x_axis = group_col
        color_axis = group_col

    # Przeliczamy na godziny i sortujemy
    agg_df['duration'] = (agg_df['duration'] / 3600).round(2)
    agg_df = agg_df.sort_values(by='duration', ascending=(True if chart_type == 'bar_h' else False))

    # Pobieramy kolory z Twojej mapy kolorów
    cols_map = {i: get_colour(str(i)) for i in agg_df[color_axis].unique()}

    # 6. Rysowanie Wykresu
    title = f"{title_prefix} - Top {limit} ({label_text})"
    
    if chart_type in ['pie', 'donut']:
        fig = px.pie(agg_df, names=x_axis, values='duration', color=color_axis,
                     color_discrete_map=cols_map, hole=0.4 if chart_type=='donut' else 0)
        fig.update_traces(textinfo='percent+label')

    elif chart_type == 'treemap':
        agg_df['root'] = title_prefix # Korzeń dla drzewa
        fig = px.treemap(agg_df, path=['root', x_axis], values='duration', color=color_axis,
                         color_discrete_map=cols_map)
        fig.update_traces(root_color="lightgrey")

    elif chart_type == 'bar_h': # porównanie 
        label_text = 'osoba' if scope == 'comparison' else label_text
        fig = px.bar(agg_df, x='duration', y=x_axis, color=color_axis, orientation='h',
                     color_discrete_map=cols_map, text_auto=True)
        # Sortowanie całkowite (najdłuższy pasek na górze)
        fig.update_layout(yaxis={'categoryorder': 'total ascending'},xaxis_title='liczba godzin',
                          legend_title_text=label_text,yaxis_title=label_text) 
        
    elif chart_type == 'bar_stack':
        # Dla comparison: Paski ułożone jeden na drugim
        fig = px.bar(agg_df, x='duration', y='osoba', color=color_axis, orientation='h',
                     color_discrete_map=cols_map, text_auto=True)
        fig.update_layout(xaxis_title='liczba godzinZ',legend_title_text=label_text,yaxis_title=label_text)
    else: # bar (pionowy) osoba
        fig = px.bar(agg_df, x=x_axis, y='duration', color=color_axis,
                     color_discrete_map=cols_map, text_auto=True)
        fig.update_layout(yaxis_title='liczba godzin',legend_title_text=label_text,xaxis_title="")
    fig.update_layout(
        title=title,
        template='plotly_white',
        margin=dict(l=20, r=20, t=50, b=20),
        legend=dict(orientation="h", y=-0.2, x=0.5, xanchor="center")
    )

    return fig
@app.callback(
    Output("timeline-top-filter", "value", allow_duplicate=True),
    [Input("timeline-btn-all", "n_clicks"),
     Input("timeline-btn-none", "n_clicks")],
    [State("timeline-top-filter", "options")],
    prevent_initial_call=True
)
def handle_select_buttons(n_all, n_none, options):
    ctx_id = ctx.triggered_id
    if ctx_id == "timeline-btn-all":
        return [opt['value'] for opt in options]
    elif ctx_id == "timeline-btn-none":
        return []
    return dash.no_update
# --- CALLBACK: RYSOWANIE WYKRESU (ZAKTUALIZOWANY) ---
@app.callback(
    Output('timeline-graph', 'figure'),
    [
        Input('timeline-user-select', 'value'),
        Input('timeline-week-select', 'value'),
        Input('timeline-slider', 'value'),
        # NOWE INPUTY
        Input('timeline-mode-switch', 'value'), # Tryb (Cat/App)
        Input('timeline-top-filter', 'value'), # Wybrane fasolki
        
        # Globalne
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value')
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')]
)
def update_timeline_graph(selected_user, start_of_week_str, slider_range, 
                          mode, selected_filters, # Nowe argumenty
                          start_date, end_date, min_dur, filter_values, afk_mode, filter_ids):
    
    if not selected_user or not start_of_week_str:
        return go.Figure().update_layout(title="Wybierz użytkownika i tydzień", template='plotly_white')

    if not slider_range: slider_range = [0, 24]

    # 1. Dane
    filtered_df = get_filtered_df(start_date, end_date, min_dur, filter_values, afk_mode, filter_ids)
    if filtered_df.empty: return go.Figure().update_layout(title="Brak danych", template='plotly_white')
    #try:
    #    filtered_df['timestamp'] = pd.to_datetime(filtered_df['timestamp']).dt.tz_convert('Europe/Warsaw') # Zapomniałeś o tym :)
    #except:
    #    filtered_df['timestamp']= pd.to_datetime(filtered_df['timestamp']).dt.tz_localize('UTC').dt.tz_convert('Europe/Warsaw')
    
   # if filtered_df['timestamp'].dt.tz is not None:
        # Używam nowej kolumny w df, ktora juz jest w strefie +1
    #    filtered_df['timestamp'] = filtered_df['timestamp_pl'].dt.tz_localize(None)
        # Tutaj nazwa timestamp jest troche niefortunna, bo może się mylić z timestamp w df, 
        # który jest niezlokalizowany (UTC + 0). W tej funkcji lokalizujemy czas, zeby porównywaź potem
        # z week_start itd, które nie mają danej strefy.
    # 2. Tydzień
    filtered_df['timestamp'] = filtered_df['localized_time_pl'] # optymalizacja
    week_start = pd.Timestamp(start_of_week_str)
    week_end = week_start + pd.Timedelta(days=7)

    df_week = filtered_df[
        (filtered_df['osoba'] == selected_user) & 
        (filtered_df['timestamp'] >= week_start) & 
        (filtered_df['timestamp'] < week_end)
    ].copy()

    if df_week.empty: return go.Figure().update_layout(title="Brak danych w tym tygodniu", template='plotly_white')

    # 3. FILTROWANIE PO FASOLKACH (Kluczowa zmiana)
    # Ustalamy kolumnę sterującą
    target_col = 'category' if mode == 'category' else ('app' if 'app' in df_week.columns else 'category')
    
    # Zostawiamy tylko to, co jest zaznaczone na liście fasolek
    if selected_filters is not None:
        df_week = df_week[df_week[target_col].isin(selected_filters)]

    if df_week.empty:
        return go.Figure().update_layout(title="Odznaczono wszystkie elementy", template='plotly_white')

    # 4. Etykiety Dni
    days_labels = []
    pl_days = ['Poniedziałek', 'Wtorek', 'Środa', 'Czwartek', 'Piątek', 'Sobota', 'Niedziela']
    for i in range(7):
        current_day = week_start + pd.Timedelta(days=i)
        label = f"{pl_days[i]} {current_day.strftime('%d.%m')}"
        days_labels.append(label)

   # 5. Agregacja
    df_week['day_index'] = (df_week['timestamp'] - week_start).dt.days
    df_week['y_label'] = df_week['day_index'].map(lambda x: days_labels[int(x)] if 0 <= x < 7 else None)
    
    # Grupujemy po target_col (żeby kolorować wg wybranego trybu)
    group_keys = [pd.Grouper(key='timestamp', freq='15min'), target_col, 'y_label']
    
    # --- POPRAWKA TUTAJ ---
    # Dodajemy 'app' do grupowania tylko jeśli istnieje I NIE JEST już wybrane jako target_col.
    # Wcześniej dodawało 'app' zawsze, co przy trybie "Aplikacje" powodowało dublowanie klucza.
    if 'app' in df_week.columns and target_col != 'app':
        group_keys.append('app')
    # ----------------------

    df_res = df_week.groupby(group_keys)['duration'].sum().reset_index()
    df_res = df_res[df_res['duration'] > 0]

    df_res['start_decimal'] = df_res['timestamp'].dt.hour + (df_res['timestamp'].dt.minute / 60)
    df_res['duration_h'] = df_res['duration'] / 3600
    df_res['start_hhmm'] = df_res['timestamp'].dt.strftime('%H:%M') # NOWE
    df_res['duration_hm'] = df_res['duration_h'].apply(lambda x: f"{int(x)}h {int(((x%1)*60))}m")    # 6. Rysowanie
    fig = go.Figure()
    
    # Unikalne elementy do legendy (Kategorie lub Aplikacje)
    unique_items = sorted(df_res[target_col].unique())

    for item in unique_items:
        subset = df_res[df_res[target_col] == item]
        custom_d = pd.DataFrame()
        custom_d[0] = subset['timestamp'].dt.strftime("%H:%M")
        custom_d[1] = round(subset['duration_h']*60, 0)
        # Tooltip content
        if 'app' in subset.columns and mode == 'category':
            # Tryb Kategoria: Pokaż nazwę apki w dymku
            custom_d[2] = subset[['app']]
            hover_tmpl = f"<b>{item}</b><br>%{{customdata[2]}}<br>Start: %{{customdata[0]}}<br>Czas: %{{customdata[1]}} min<extra></extra>"
        else:
            # Tryb App: Pokaż po prostu nazwę (item)
            custom_d[2] = subset[[target_col]] # dummy
            hover_tmpl = f"<b>{item}</b><br>Start: %{{customdata[0]}}<br>Czas: %{{customdata[1]}} min<extra></extra>"

        fig.add_trace(go.Bar(
            y=subset['y_label'],
            x=subset['duration_h'],
            base=subset['start_decimal'],
            orientation='h',
            name=str(item), # To co w legendzie
            hovertemplate=hover_tmpl,
            customdata=custom_d,
            width=0.8,
            opacity=0.8 if (str(item).lower() != 'sen') else 0.4,
            marker=dict(
                color=get_colour(str(item)),
                line=dict(width=0)),

        ))

    # 7. Layout
    fig.update_layout(
        title=f"Harmonogram ({'Kategorie' if mode=='category' else 'Aplikacje'}): {selected_user} (Start: {week_start.strftime('%Y-%m-%d')})",
        height=600,
        template='plotly_white',
        barmode='stack',
        yaxis=dict(title="", categoryorder='array', categoryarray=days_labels, autorange="reversed", showgrid=True, gridcolor='#f0f0f0'),
        xaxis=dict(title="Godzina Dnia", range=slider_range, tickmode='linear', dtick=1, showgrid=True, gridcolor='#e0e0e0', zeroline=False, side='top'),
        legend=dict(orientation="h", y=-0.1, x=0.5, xanchor="center"),
        margin=dict(l=100, r=20, t=80, b=40)
    )

    return fig


# --- CALLBACK A: AKTUALIZACJA OPCJI W DROP-DOWNACH ---
@app.callback(
    [
        Output('timeline-user-select', 'options'),
        Output('timeline-user-select', 'value'),
        Output('timeline-week-select', 'options'),
        Output('timeline-week-select', 'value')
    ],
    [
        Input('timeline-user-select', 'value'), # Żeby zachować wybór przy odświeżaniu
        Input('timeline-week-select', 'value'),
        # Globalne triggery
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value')
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')]
)
def update_timeline_controls(current_user, current_week, start_date, end_date, min_dur, filter_values, afk_mode, filter_ids):
    # 1. Filtrujemy dane globalnie (tą samą funkcją co zawsze)
    filtered_df = get_filtered_df(start_date, end_date, min_dur, filter_values, afk_mode, filter_ids)
    
    if filtered_df.empty:
        return [], None, [], None

    # 2. Lista Użytkowników
    users = sorted(filtered_df['osoba'].astype(str).unique())
    user_opts = [{'label': '👤 '+u, 'value': u} for u in users]
    
    # Logika wyboru usera (jeśli obecny jest na liście, zostaw go, inaczej wybierz pierwszego)
    selected_user = current_user if current_user in users else users[0]

    # 3. Lista Tygodni (Dla wybranego usera!)
    user_df = filtered_df[filtered_df['osoba'] == selected_user]
    week_opts = get_week_options(user_df)
    
    # Logika wyboru tygodnia (jeśli obecny jest na liście, zostaw go, inaczej weź najnowszy)
    available_weeks = [opt['value'] for opt in week_opts]
    selected_week = current_week if current_week in available_weeks else (available_weeks[0] if available_weeks else None)

    return user_opts, selected_user, week_opts, selected_week
# --- CALLBACK B: RYSOWANIE WYKRESU TYGODNIOWEGO ---
@app.callback(
    Output('weekly_hours_plotly', 'figure'),
    [
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value'),
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')],
    Input('Wybor-osoby-weekly-time','value'),
    Input('Wybor-kateg-weekly-time','value'),
    Input('TopN-app-weekly','value')
)
def weekly_screentime(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids,osoba,agregator,topn):
    filtered_df = get_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids)
    filtered_df = filtered_df[filtered_df['category'] != 'sen']
    # W trybie app, bierzemy topn aplikacji (liczymy dla konkretnej osoby)
    if agregator == 'app':
        Popular_apps = filtered_df[filtered_df['osoba']==osoba].groupby('app')['duration'].aggregate(total_duration = 'sum').reset_index()
        Popular_apps = Popular_apps.sort_values('total_duration',ascending=False).reset_index(drop=True)
        Popular_apps = Popular_apps.head(topn)
        filtered_df = filtered_df[filtered_df['app'].isin(Popular_apps['app'])]    # dodajemy kolumny z nazwą i numerem tygodnia i godziną
    #timestamp = filtered_df['timestamp']
    #timestamp_pl = timestamp.dt.tz_convert('Europe/Warsaw')
    #filtered_df['timestamp_pl'] = timestamp_pl
    #filtered_df['day_of_year'] = timestamp_pl.dt.day_of_year
    #filtered_df['weekday'] = timestamp_pl.dt.day_name('Pl')
    #filtered_df['weekday_number'] = timestamp_pl.dt.weekday + 1
    #filtered_df['hour'] = timestamp_pl.dt.hour
    # Obliczam średni czas aktywności w danym dnium tygodniaz podziałem na kategorie
    # Zliczam ile razy u danej osoby wystąpił dany dzień tygodnia
    Dni = filtered_df[['osoba',"weekday","weekday_number","day_of_year"]].drop_duplicates()
    Dni = Dni.groupby(["osoba","weekday","weekday_number"])['day_of_year'].aggregate(n = 'count').reset_index().sort_values(['osoba','weekday_number'])

    df2 = filtered_df.groupby(["osoba","weekday","weekday_number",agregator])['duration'].aggregate(total_activity = 'sum').reset_index()
    df2['total_activity'] /= 3600
    # Teraz podzilić przez liczbę zarejestrowanych dni
    df2 = pd.merge(df2,Dni)
    df2['average_activity'] = df2['total_activity'] / df2['n']
    # Tworze wykres
    # Podpis legendy
    tytuly = {'category': 'kategorie','app': 'aplikacje'}
    df3 = df2[df2['osoba'] == osoba]
    cols2 = {i: get_colour(i) for i in df3[agregator]}

    #ylim = np.ceil(df2.groupby(['osoba','weekday'])['average_activity'].sum().reset_index()['average_activity'].max())
    df3['average_activity_hm'] = df3['average_activity'].apply(lambda x: f"{int(x)}h {int(((x%1)*60))}m")
    
    fig = px.bar(df3,
            x='weekday',
            y = 'average_activity',
            color=agregator,
            color_discrete_map=cols2,
            category_orders={'weekday':['Poniedziałek','Wtorek','Środa','Czwartek','Piątek','Sobota','Niedziela']},
            labels={'weekday':'dzień tygodnia','average_activity':'średnia aktywność (godz.)',agregator:tytuly.get(agregator)},
            title=f"Średnia aktywność w dniach tygodnia: {osoba}",
            template='plotly_white',
            #range_y=[0,ylim],
            hover_data={
            agregator: True,                # pokaż nazwę aplikacji/kategorii
            'average_activity_hm': True,    # pokaż czas w Hh Mm
            'average_activity': True,        # ukryj dziesiętne godziny
            'weekday':False
            })
    for trace in fig.data:
        # bierzemy tylko wiersze df3, które pasują do tego trace (trace.name = nazwa grupy)
        subset = df3[df3[agregator] == trace.name].copy()
        trace.customdata = np.stack(
            (subset[agregator], subset['average_activity_hm']), axis=-1
        )
        trace.hovertemplate = (
            "<b>%{customdata[0]}</b><br>"
            "Czas średni: %{customdata[1]}"
            "<extra></extra>"
        )
    return fig
# --- CALLBACK C: LINIA AKTYWNOŚCI
@app.callback(
    Output('activity-line-plot', 'figure'),
    [
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value'),
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')],
    Input("highlight-options", "value")
)
def activity_line(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids, highlight_options):
    filtered_df = get_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids)
    filtered_df = filtered_df[filtered_df['category'] != 'sen']
    if filtered_df.empty:
        return go.Figure().update_layout(title="Brak danych dla wybranych filtrów")

    Suma_z_dnia = filtered_df.groupby(['osoba','date'])['duration'].sum().reset_index().sort_values('duration',ascending=False)
    Suma_z_dnia['duration'] = round(Suma_z_dnia['duration'] / 3600,2)
    #Suma_z_dnia = Suma_z_dnia.sort_values(['osoba','date']) 
    # Uzupełniam brakujące dni zerami
    osoby = Suma_z_dnia['osoba'].unique()
    daty = pd.date_range(Suma_z_dnia['date'].min(), Suma_z_dnia['date'].max())

    full_index = pd.MultiIndex.from_product([osoby, daty], names=['osoba', 'date'])
    Suma_z_dnia = Suma_z_dnia.set_index(['osoba', 'date']).reindex(full_index, fill_value=0).reset_index()
    Suma_z_dnia = Suma_z_dnia.sort_values(["osoba","date"]).reset_index(drop=True)
    Suma_z_dnia['duration_hm'] = Suma_z_dnia['duration'].apply(lambda x: f"{int(x)}h {int((x%1*60))}m")

    fig = px.line(
    Suma_z_dnia,
    x='date',
    y='duration',
    color='osoba',         # każda osoba będzie miała osobną linię
    labels={'date':'Data', 'duration':'Czas aktywności', 'osoba':'Osoba'},
   # title='Dzienna aktywność',
    template='plotly_white',
    line_shape='spline',
    category_orders={'osoba':OSOBY}
    )

    # wymuszenie chronologicznej kolejności X, jeśli daty są datetime to Plotly zrobi to automatycznie
    fig.update_yaxes(ticksuffix="h")
    fig.update_layout(xaxis_tickangle=-45)  # dla czytelności etykiet dat
    fig.update_traces(line=dict(width=4))  # np. 4 piksele

    start = Suma_z_dnia['date'].min()
    end = Suma_z_dnia['date'].max()
    tick_vals = pd.date_range(start, end, freq='2D')  # co 2 dni
    fig.update_xaxes(tickvals=tick_vals, tickformat="%Y-%m-%d")
    for trace in fig.data:
        osoba = trace.name  # nazwa linii = osoba
        # filtrujemy dane tylko dla tej osoby
        df_osoba = Suma_z_dnia[Suma_z_dnia['osoba'] == osoba]
        # przypisujemy customdata dla tej linii
        trace.customdata = df_osoba[['duration_hm']].values
        # własny hovertemplate
        trace.hovertemplate = (
            f"<b>{osoba}</b><br>"       # nazwa osoby
            "Data: %{x|%Y-%m-%d}<br>"   # data
            "Czas aktywności: %{customdata[0]}<extra></extra>"  # Hh Mm
        )
    # -------------------
    # Dodawanie weekendów
    # -------------------
    if ('weekend' in highlight_options):
        current = start
        while current <= end:
            if current.weekday() >= 5:
            # jeśli dzień to sobota (5) lub niedziela (6)
                fig.add_vrect(
                    x0=current-pd.Timedelta(hours=12),
                    x1=current+pd.Timedelta(hours=12),
                    fillcolor="lightgrey",
                    opacity=0.5,
                    layer="below",
                    line_width=0
                )
            current += pd.Timedelta(days=1)
    if ('holiday' in highlight_options):
        # Święta
        # Załóżmy, że przerwa świąteczna trwa od 24 grudnia do 26 grudnia
        holiday_start = pd.to_datetime("2025-12-24")
        holiday_end   = pd.to_datetime("2026-01-06")

        fig.add_vrect(
            x0=holiday_start,
            x1=holiday_end,
            fillcolor="red", # np. czerwony pasek
            opacity=0.15,     # półprzezroczysty
            layer="below",
            line_width=0,
            annotation=dict(
                text="<b>Przerwa świąteczna</b>", # napis
                x=(holiday_start + (holiday_end - holiday_start)/2), # środek prostokąta
                y=1.1,                      # na samej górze wykresu
                showarrow=False,
                font=dict(size=20, color="red", family="Arial"), # większa i kolorowa czcionka
                xanchor="center"
                )
        )
    
    return fig
@app.callback(
    Output('TopN-col', 'style'),
    Input('Wybor-kateg-weekly-time', 'value')
)
def show_topn_col(agregator):
    if agregator == 'app':
        return {'visibility': 'visible'}
    return {'visibility': 'hidden'}    

    
        
        

@app.callback(
    [
        Output({'type': 'device-filter', 'user': MATCH, 'device': ALL}, 'value'),
        Output({'type': 'device-filter', 'user': MATCH, 'device': ALL}, 'disabled'),
        Output({'type': 'device-filter', 'user': MATCH, 'device': ALL}, 'label_class_name')
    ],
    [Input({'type': 'user-master-switch', 'user': MATCH}, 'value')],
    [
        State({'type': 'device-filter', 'user': MATCH, 'device': ALL}, 'id'),
        State({'type': 'user-memory', 'user': MATCH}, 'data') # Pobieramy pamięć
    ]
)
def toggle_user_devices(master_switch_on, device_ids, saved_memory):
    new_values = []
    new_disabled = []
    new_classes = []
    
    # Pobieramy info o dostępności danych (z DF)
    # Uwaga: Musimy wiedzieć, czy dane w ogóle istnieją, żeby nie włączyć "pustego" urządzenia
    # nawet jak pamięć mówi True (np. z błędu).
    current_user = device_ids[0]['user']
    user_data = df[df['osoba'] == current_user]
    existing_devices = set(user_data['device'].unique()) # Set dla szybkości
    
    base_class = "btn btn-outline-primary rounded-pill me-2 mb-1"

    for dev_id in device_ids:
        device_name = dev_id['device']
        has_data = device_name in existing_devices
        
        if not master_switch_on:
            # WYŁĄCZANIE: Wszystko gaśnie
            new_values.append(False)
            new_disabled.append(True)
            new_classes.append(f"{base_class} disabled opacity-25")
        else:
            # WŁĄCZANIE: Przywracamy z pamięci
            # Sprawdzamy co było w pamięci. Domyślnie (jeśli brak w pamięci) -> True (o ile ma dane)
            should_be_checked = saved_memory.get(device_name, True) if saved_memory else True
            
            if has_data:
                # Jeśli urządzenie ma dane i było zaznaczone w pamięci -> Włączamy
                is_checked = should_be_checked
                new_values.append(is_checked)
                new_disabled.append(False)
                # Klasa zależy od tego czy zaznaczone (estetyka) - tu zawsze aktywna
                new_classes.append(base_class) 
            else:
                # Brak danych -> Zawsze wyłączone
                new_values.append(False)
                new_disabled.append(True)
                new_classes.append(f"{base_class} disabled opacity-50")

    return new_values, new_disabled, new_classes  
#endregion
@app.callback(
    Output({'type': 'user-memory', 'user': MATCH}, 'data'),
    Input({'type': 'device-filter', 'user': MATCH, 'device': ALL}, 'value'),
    State({'type': 'user-master-switch', 'user': MATCH}, 'value'),
    State({'type': 'device-filter', 'user': MATCH, 'device': ALL}, 'id'),
    State({'type': 'user-memory', 'user': MATCH}, 'data'),
    prevent_initial_call=True
)
def save_user_state(checkbox_values, is_master_on, checkbox_ids, current_memory):
    # Jeśli Master jest wyłączony, to znaczy, że zmiana wartości wynika 
    # z automatycznego wygaszania pastylek. NIE ZAPISUJEMY TEGO.
    if not is_master_on:
        return dash.no_update

    # Jeśli Master jest włączony, to użytkownik klika pastylki. ZAPISUJEMY.
    # Mapujemy listę wartości [True, False, True] na słownik {'PC': True, 'Phone': False...}
    new_memory = current_memory.copy() if current_memory else {}
    
    for val, id_dict in zip(checkbox_values, checkbox_ids):
        device_name = id_dict['device']
        new_memory[device_name] = val
        
    return new_memory
    
@app.callback(
    [
        Output("sidebar", "is_open"),         # 1. Stan Sidebara
        Output("filters-offcanvas", "is_open"), # 2. Stan Filtrów
        Output("filters-offcanvas", "style"), # 3. Pozycja Filtrów
        Output("extra-offcanvas", "is_open"), # 4. Stan Extra
        Output("extra-offcanvas", "style"),   # 5. Pozycja Extra
    ],
    [
        Input("sidebar-toggle", "n_clicks"),
        Input("open-filters-btn", "n_clicks"),
        # Input("open-extra-btn", "n_clicks"), #n_extra
    ],
    [
        State("sidebar", "is_open"),
        State("filters-offcanvas", "is_open"),
        State("extra-offcanvas", "is_open"),
    ]
)
def manage_layout(n_side, n_filt, side_open, filt_open, extra_open):
    # Sprawdzamy, który guzik został kliknięty
    ctx_id = ctx.triggered_id

    # 1. AKTUALIZACJA STANÓW (OTWARTE/ZAMKNIĘTE)
    if ctx_id == "sidebar-toggle":
        side_open = not side_open
    elif ctx_id == "open-filters-btn":
        filt_open = not filt_open
    # elif ctx_id == "open-extra-btn":
    #     extra_open = not extra_open

    # 2. OBLICZANIE PUNKTU STARTOWEGO (OFFSET)
    # Jeśli sidebar otwarty, startujemy od 16rem. Jeśli zamknięty, od 0.
    # Uwaga: 16rem to ok. 256px, ale dla bezpieczeństwa w CSS użyjemy stringa calc()
    base_offset_css = "16rem" if side_open else "0px"

    # 3. OBLICZANIE POZYCJI PANELI (LOGIKA SLOTÓW)
    
    # Styl bazowy
    style_filt = get_base_panel_style()
    style_extra = get_base_panel_style()

    # --- Logika dla Panelu 1 (Filtry) ---
    # Filtry zawsze chcą być pierwsze (Slot 1)
    style_filt["left"] = base_offset_css
    
    # --- Logika dla Panelu 2 (Extra) ---
    if filt_open:
        # Jeśli Filtry są otwarte, Extra musi stanąć OBOK nich (Slot 2)
        # Używamy CSS calc: Base + Szerokość Panelu
        style_extra["left"] = f"calc({base_offset_css} + {PANEL_WIDTH})"
    else:
        # Jeśli Filtry są zamknięte, Extra zajmuje pierwsze wolne miejsce (Slot 1)
        style_extra["left"] = base_offset_css

    # 4. ZWROT WYNIKÓW
    return side_open, filt_open, style_filt, extra_open, style_extra

content_sleep = html.Div([
    dbc.Card(dbc.CardBody([
        dbc.Row([dbc.Col(html.H4("Dzienna długość snu")),dbc.Col([
                            html.H5("Zaznacz"),
                            dbc.Checklist(
                                options=[
                                    {"label": "Weekendy", "value": "weekend"},
                                    #{"label": "Poniedziałki", "value": "weekend_mon"},
                                    {"label": "Święta", "value": "holiday"}
                                    ],
                                    value=["weekend","holiday"], # domyślnie zaznaczone
                                    id="highlight-options",
                                    inline=True          # checkboxy w jednej linii
                                )]
        )]),
        dcc.Graph(id='sleep-line-plot',config={'displayModeBar': False})
     ])),
        dbc.Card(
            dbc.CardBody([
                # Nagłówek i opcje w osobnym Row (w pionie w Card)
                dbc.Row([
                    dbc.Col(html.H4("Godzinowy układ snu"), width=12, md=3),
                    dbc.Col([
                        dbc.Button("Zaznacz", id="select-all-days", size="sm"),
                        dbc.Button("Odznacz", id="deselect-all-days", size="sm"),
                    ], class_name="mb-2 g-2", width=12, md=1),
                    dbc.Col([
                        html.H5("Wybierz dni tygodnia"),
                        dbc.Checklist(
                            options=[
                                {"label": "Poniedziałki", "value": "0"},
                                {"label": "Wtorki", "value": "1"},
                                {"label": "Środy", "value": "2"},
                                {"label": "Czwartki", "value": "3"},
                                {"label": "Piątki", "value": "4"},
                                {"label": "Soboty", "value": "5"},
                                {"label": "Niedziele", "value": "6"},
                            ],
                            value=["0","1","2","3","4","5","6"],
                            id="highlight-options-3",
                            inline=True
                        )
                    ], width=12, md=6),
                    dbc.Col([
                        html.H5("Zaznaczenia"),
                        dbc.Checklist(
                            options=[
                                {"label": html.Div(["Wyróżnij weekendy", html.Br(), "(na zielono)"]), "value": "a"}
                            ],
                            value=["a"],
                            id="highlight-options-2",
                            inline=True
                        )
                    ], width=12, md=2)
                ], class_name='align-items-center g-2'),
                # Wykresy 
                dbc.Row([
                dbc.Col(dcc.Graph(id='sleep-times-plot', config={'displayModeBar': False}),width=6),#style={'height': '500px'}
                dbc.Col(dcc.Graph(id='sleep_violin', config={'displayModeBar': False,'staticPlot': True }),width=6)
                ])
            ])
        )
])
@app.callback(
    Output("highlight-options-3", "value"),
    Input("select-all-days", "n_clicks"),
    Input("deselect-all-days", "n_clicks"),
    prevent_initial_call=True
)
def select_deselect_all(select_clicks, deselect_clicks):
    ctx = dash.callback_context
    if not ctx.triggered:
        raise dash.exceptions.PreventUpdate

    button_id = ctx.triggered[0]["prop_id"].split(".")[0]

    if button_id == "select-all-days":
        return ["0","1","2","3","4","5","6"]
    elif button_id == "deselect-all-days":
        return []
# --- VIOLIN PLOT SEN
@app.callback(
    [
        Output('sleep_violin','figure')
    ],
    [
        # Globalne triggery
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value')
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')],
    Input("highlight-options-3", "value"), # Dni tygodnia
    Input("highlight-options-2", "value") # Weekendy
)
def update_sleep_violin(start_date, end_date, min_dur, filter_values, afk_mode, filter_ids,highlight_options_3, highlight_options_2):
    if(len(highlight_options_3) == 0):
        fig = go.Figure()
        fig.update_layout(
            title="Brak danych",
            xaxis={"visible": False},
            yaxis={"visible": False},
            template="plotly_white"
        )
        return [fig]

    sdf = get_filtered_df(start_date, end_date, min_dur, filter_values, afk_mode, filter_ids)

    sdf = sdf[sdf['status']=='sleep'].reset_index(drop=True)
    sdf['duration'] /= 3600

    # sen rozpoczęty wczoraj przenosimy na kolejny dzień
    sdf.loc[sdf.timestamp_pl.dt.hour > 18,'day_of_year'] += 1
    sdf.loc[sdf.timestamp_pl.dt.hour > 18,'weekday_number'] =(sdf.loc[sdf.timestamp_pl.dt.hour > 18,'weekday_number']+1)%  7

    sdf.loc[sdf.day_of_year == 366,'day_of_year'] = 1

    # Odfiltruj dni tygodna wskazane przez użytkownika
    # highlight-options-3 - lista numerów dni tygodnia
    highlight_options_3 = [int(i) for i in highlight_options_3]
    sdf = sdf[sdf.weekday_number.isin(highlight_options_3)]
    fig = go.Figure()

    if "a" not in highlight_options_2:
        sdf2 = sdf.groupby(['osoba','day_of_year'])['duration'].sum().reset_index(drop=False)
        tr = go.Violin(x=sdf2['osoba'], y=sdf2['duration'], points=False, width=0.82)
        tr.marker.color = get_colour('sen')
        fig.add_trace(
            tr
        )


    else: # Osobno weekendy
        # weekend = sobota (5) i niedziela (6)
        fig = go.Figure()
        sdf_weekend = sdf[sdf['weekday_number'].isin([5,6])].groupby(['osoba','day_of_year'])['duration'].sum().reset_index(drop=False)
        sdf_workday = sdf[~sdf['weekday_number'].isin([5,6])].groupby(['osoba','day_of_year'])['duration'].sum().reset_index(drop=False)
        for name, colour, i in zip(['Workday', 'Weekend'], [get_colour('weekend'), get_colour('sen')], [sdf_weekend, sdf_workday]):
            if not i.empty:
                trace_weekend = go.Violin(
                    x=i['osoba'], y=i['duration'], points=False
                )
                trace_weekend.name = name
                trace_weekend.marker.color = colour
                fig.add_trace(trace_weekend)
                trace_weekend.width = 0.26

    fig.update_layout(yaxis_title='liczba godzin',
                    template='plotly_white',
                    xaxis_title="",
                    violinmode='group',violingap=0.01,
                    title="Rozkład czasu snu")
    
    fig.update_yaxes(
        tickfont=dict(size=18)
    )
    fig.update_xaxes(
        tickfont=dict(size=18)
    )
    return [fig]

@app.callback(
    Output('sleep-line-plot', 'figure'),
    [
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value'),
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')],
    Input("highlight-options", "value")
)
def sleep_activity_line(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids, highlight_options):
    
    filtered_df = create_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids, get_sleep=True)
    filtered_df = filtered_df.loc[(df['category'] == 'sen')]
    if filtered_df.empty:
        return go.Figure().update_layout(title="Brak danych dla wybranych filtrów")
    # Zmiana na czas polski
    # timestamp = filtered_df['timestamp']
    # try:
    #     timestamp_pl = timestamp.dt.tz_convert('Europe/Warsaw')
    # except:
    #     timestamp_pl = timestamp.dt.tz_localize('UTC').dt.tz_convert('Europe/Warsaw')
    
    # POWYŻSZE JUŻ NIE POTRZEBNE
    timestamp_pl = filtered_df['timestamp_pl']
    # DALEJ BEZ ZMIAN

    # trik: "dzień" dla snu trwa od 20:00 dnia poprzedniego do 19:59    
    filtered_df['timestamp_pl'] = timestamp_pl+pd.Timedelta(hours=4)
    filtered_df['date'] = filtered_df['timestamp_pl'].dt.date

    Suma_z_dnia = filtered_df.groupby(['osoba','date'])['duration'].sum().reset_index().sort_values('duration',ascending=False)
    Suma_z_dnia['duration'] = round(Suma_z_dnia['duration'] / 3600,2)
    Suma_z_dnia = Suma_z_dnia.sort_values(['osoba','date']) 
    # Uzupełniam brakujące dni zerami
    osoby = Suma_z_dnia['osoba'].unique()
    daty = pd.date_range(Suma_z_dnia['date'].min(), Suma_z_dnia['date'].max())

    full_index = pd.MultiIndex.from_product([osoby, daty], names=['osoba', 'date'])
    Suma_z_dnia = Suma_z_dnia.set_index(['osoba', 'date']).reindex(full_index, fill_value=0).reset_index()
    Suma_z_dnia.sort_values(["osoba","date"]).reset_index(drop=True)
    Suma_z_dnia['duration_hm'] = Suma_z_dnia['duration'].apply(lambda x: f"{int(x)}h {int((x%1*60))}m")

    fig = px.line(
    Suma_z_dnia,
    x='date',
    y='duration',
    color='osoba',         # każda osoba będzie miała osobną linię
    labels={'date':'Data', 'duration':'Czas snu', 'osoba':'Osoba'},
   # title='Dzienna aktywność',
    template='plotly_white',
    line_shape='spline',
    category_orders={'osoba':OSOBY}
    )

    # wymuszenie chronologicznej kolejności X, jeśli daty są datetime to Plotly zrobi to automatycznie
    fig.update_yaxes(ticksuffix="h")
    fig.update_layout(xaxis_tickangle=-45)  # dla czytelności etykiet dat
    fig.update_traces(line=dict(width=4))  # np. 4 piksele

    start = Suma_z_dnia['date'].min()
    end = Suma_z_dnia['date'].max()
    tick_vals = pd.date_range(start, end, freq='2D')  # co 2 dni
    fig.update_xaxes(tickvals=tick_vals, tickformat="%Y-%m-%d")
    for trace in fig.data:
        osoba = trace.name  # nazwa linii = osoba
        # filtrujemy dane tylko dla tej osoby
        df_osoba = Suma_z_dnia[Suma_z_dnia['osoba'] == osoba]
        # przypisujemy customdata dla tej linii
        trace.customdata = df_osoba[['duration_hm']].values
        # własny hovertemplate
        trace.hovertemplate = (
            f"<b>{osoba}</b><br>"       # nazwa osoby
            "Data: %{x|%Y-%m-%d}<br>"   # data
            "Czas snu: %{customdata[0]}<extra></extra>"  # Hh Mm
        )
    # -------------------
    # Dodawanie weekendów
    # -------------------
    if ('weekend' in highlight_options):
        current = start
        while current <= end:
            if current.weekday() >= 5:
            # jeśli dzień to sobota (5) lub niedziela (6)
                fig.add_vrect(
                    x0=current-pd.Timedelta(hours=12),
                    x1=current+pd.Timedelta(hours=12),
                    fillcolor="lightgrey",
                    opacity=0.5,
                    layer="below",
                    line_width=0
                )
            current += pd.Timedelta(days=1)
    if ('holiday' in highlight_options):
        # Święta
        # Załóżmy, że przerwa świąteczna trwa od 24 grudnia do 26 grudnia
        holiday_start = pd.to_datetime("2025-12-24")
        holiday_end   = pd.to_datetime("2026-01-06")

        fig.add_vrect(
            x0=holiday_start,
            x1=holiday_end,
            fillcolor="red", # np. czerwony pasek
            opacity=0.15,     # półprzezroczysty
            layer="below",
            line_width=0,
            annotation=dict(
                text="<b>Przerwa świąteczna</b>", # napis
                x=(holiday_start + (holiday_end - holiday_start)/2), # środek prostokąta
                y=1.1,                      # na samej górze wykresu
                showarrow=False,
                font=dict(size=20, color="red", family="Arial"), # większa i kolorowa czcionka
                xanchor="center"
                )
        )
    
    return fig


@app.callback(
    Output('sleep-times-plot', 'figure'),
    [
        Input('watcher-date-picker', 'start_date'),
        Input('watcher-date-picker', 'end_date'),
        Input('min-duration-input', 'value'),
        Input({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'value'),
        Input('afk-mode-selector', 'value'),
    ],
    [State({'type': 'device-filter', 'user': ALL, 'device': ALL}, 'id')],
    Input("highlight-options-3", "value"), # Dni tygodnia
    Input("highlight-options-2", "value") # Weekendy
)
def sleep_times_plotter(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids, highlight_options_3, highlight_options_2):
    if(len(highlight_options_3) == 0):
        fig = go.Figure()
        fig.update_layout(
            title="Brak danych",
            xaxis={"visible": False},
            yaxis={"visible": False},
            template="plotly_white"
        )
        return fig
    highlight_options_3 = [int(i) for i in highlight_options_3]
    maxd = max(highlight_options_3)
    if(0 in highlight_options_3):
        highlight_options_3.append(7)
    df_sleep = get_filtered_df(start_date, end_date, min_duration, filter_values, afk_mode, filter_ids)
    df_sleep = df_sleep[df_sleep['status']=='sleep']
    if df_sleep.empty: return go.Figure().update_layout(title="Brak danych", template='plotly_white')
    fig = go.Figure()
    fig.update_yaxes(categoryorder='array', categoryarray=pd.unique(df_sleep['osoba']))
    #df_sleep['timestamp'] = df_sleep['timestamp'].dt.tz_convert("Etc/GMT-1")
    # to już mamy zapisane w głównej ramce
    df_sleep['timestamp'] = df_sleep['timestamp_pl']
    # Dalej bez zmian
    df_sleep['tm'] = df_sleep['timestamp'].dt.hour + df_sleep['timestamp'].dt.minute / 60
    start_hour = max(18, min(np.floor((df_sleep['tm'])[df_sleep['tm'] > 18])))
    df_tmp = df_sleep.loc[df_sleep['timestamp'].dt.hour < 18]
    max_hour = np.max(np.ceil(df_tmp['tm']+(df_tmp['duration']/3600)))
    df_sleep['tm'] = np.where(df_sleep['tm']<=max_hour, df_sleep['tm']+24, df_sleep['tm'])
    hour_range = np.arange(start_hour, max_hour+24)
    fig.update_layout(
        barmode='overlay',
        xaxis=dict(
            title="Godzina",
            range=[start_hour, (max_hour+24)-2],
            tickvals=hour_range,
            ticktext=(((np.where(hour_range>=24, np.where(hour_range>=28, hour_range-22, hour_range-24), hour_range)).astype(np.int8)).astype(str).astype(object))+':00',
        ),
        showlegend=False,
        yaxis_title="Osoba",
        template='plotly_white'
    )
    osoba_number = (df_sleep.groupby('osoba').size())*(7/len(highlight_options_3))
    hover_tmpl = f"Data:%{{customdata[0]}}<br>Od:%{{customdata[1]}}<br>Do:%{{customdata[2]}}<extra></extra>"
    y_map = {osoba: i for i, osoba in enumerate(pd.unique(df_sleep['osoba']))}
    for item in df_sleep.itertuples():
        day_flag = item.timestamp.hour < 20
        if (item.timestamp.weekday() not in highlight_options_3 and day_flag) or (item.timestamp.weekday()+1 not in highlight_options_3 and not day_flag):
            continue
        custom_data = [None, None, None]
        custom_data[0] = (item.timestamp+pd.Timedelta(days=int(not day_flag))).strftime("%d.%m.%Y")
        custom_data[1] = (item.timestamp).strftime("%H:%M:%S")
        custom_data[2] = (item.timestamp+pd.Timedelta(seconds=item.duration)).strftime("%H:%M:%S")
        colour = get_colour('sen')
        offset = 0
        opacity_multiplier = 1
        length = item.duration/3600
        if (("a" in highlight_options_2) and ((item.timestamp.weekday() >= 5 and day_flag) or (item.timestamp.weekday() in [4, 5] and (not day_flag)))):
            colour = get_colour('weekend')
            offset = 0.45
            opacity_multiplier = 6/len([i for i in highlight_options_3 if i in range(5, 7)])
        elif("a" in highlight_options_2 and maxd >= 5):
            opacity_multiplier = 6/len([i for i in highlight_options_3 if i in range(0, 5)])
        else:
            opacity_multiplier = 6/len([i for i in highlight_options_3 if i != 7])
        if(item.tm+(item.duration/3600) in range(27, 30)):
            length = 3-(item.tm-24) + (1/3)*(length+(item.tm-24)-3)
        elif(item.tm+(item.duration/3600) >= 30):
            length -= 2
        if(item.tm in range(27, 30)):
            item.tm = ((item.tm-27)*(1/3))+27
        if(item.tm > 30):
            item.tm -= 2
        fig.add_trace(
            go.Bar(
            y=[y_map[item.osoba]+offset],
            x=[length],
            base=[item.tm],
            orientation='h',
            name='',
            hovertemplate=hover_tmpl,
            customdata=[custom_data],
            width=0.35+(0.45 if ("a" not in highlight_options_2 or maxd < 5) else 0),
            opacity=(1 - (0.3)**(1/(osoba_number.loc[item.osoba])))*(opacity_multiplier),
            marker=dict(
                color=colour,
                line=dict(width=0)),
            )
        )
        fig.update_xaxes(
            tickfont=dict(size=14)
        )
    fig.update_yaxes(
        tickvals=list(y_map.values()),
        ticktext=list(y_map.keys()),
        tickfont=dict(size=18),
    )
    fig.update_layout(
        margin=dict(l=50, r=20, t=0, b=50),
        height=400 + 40*len(y_map),
    )
    fig.add_annotation(
        x=27.5,
        y=-0.05,
        xref="x",
        yref="paper",
        text="//",
        showarrow=False,
        font=dict(size=20, color="black"),
        align="center",
    )
    return fig

content_intro = dbc.Container(
    [
        html.H2("", className="mb-4"),
        dbc.Row(
            [
                dbc.Col(
                    [
                        dbc.Card(
                            dbc.CardBody(
                                [
                                    html.H3("Wprowadzenie"),
                                    html.P("Projekt „JA”. Tematem projektu jest analiza wykorzystania czasu przez członków zespołu, poprzez agregację i wizualizację danych pochodzących z monitora aktywności zainstalowanego na telefonach oraz komputerach oraz danych dot. snu."),
                                    html.H3("Strony"),
                                    dbc.ListGroup(
                                        [
                                            dbc.ListGroupItem(
                                                [
                                                    html.H4("Wczytane dane"),
                                                    html.P(
                                                        f"Strona przedstawiająca aktualnie wczytane pliki wg osoby oraz urządzenia, zawierająca informacje techniczne na temat wykorzystanych danych. Aktualnie wczytanych jest {len([name for name in os.listdir(f'{prefix}/Dane Dash')])} plików."
                                                    ),
                                                ],
                                            className="py-0"),
                                            dbc.ListGroupItem(
                                                [
                                                    html.H4("Obserwatorium"),
                                                    html.P(
                                                        "Wykresy przedstawiają zgrupowane dane z aktywności użytkowników."
                                                    ),
                                                    dbc.ListGroup(
                                                        [
                                                            dbc.ListGroupItem(
                                                                html.P(
                                                                    "Zgrupowane dane: aktywność podzielona na kategorie oraz według aplikacji. Dostępne jest porównanie użytkowników oraz wizualizacje dla jednej osoby."
                                                                ),
                                                            className="py-0"),
                                                            dbc.ListGroupItem(
                                                                html.P(
                                                                    "Typowy tydzień: średnia aktywność według dnia tygodnia z podziałem na kategorie lub według aplikacji dla wybranej osoby."
                                                                ),
                                                            className="py-0"),
                                                            dbc.ListGroupItem(
                                                                html.P(
                                                                    "Dzienna aktywność: sumaryczna aktywność z podziałem na osoby w każdym dniu."
                                                                ),
                                                            className="py-0"),
                                                        ]
                                                    ),
                                                ],
                                            className="py-0"),
                                            dbc.ListGroupItem(
                                                [
                                                    html.H4("Oś czasu"),
                                                    html.P("Dokładne przedstawienie aktywności wybranego użytkownika. Zwizualizowana jest każda aktywność niezależnie od długości czy znaczenia, filtrowanie zostaje pozostawione użytkownikowi. Dostępne jest filtrowanie wg kategorii, aplikacji, godziny, tygodnia i osoby. Na osi czasu przedstawiony jest także sen.")
                                                ],
                                            className="py-0"),
                                            dbc.ListGroupItem(
                                                [
                                                    html.H4("Sen"),
                                                    html.P("Wykresy przedstawiające czas i układ godzinowy snu każdego z użytkowników."),
                                                    dbc.ListGroup([
                                                        dbc.ListGroupItem(
                                                            html.P("Dzienna długość snu: wykres przedstawiający długość snu w każdym dniu w celu zwizualizowania trendów czasowych."),
                                                        className="py-0"),
                                                        dbc.ListGroupItem(
                                                            html.P("Godzinowy układ snu: wizualizacja każdego okresu snu przedstawiająca częstotliwość snu w danych godzinach, z możliwością oddzielenia weekendów oraz filtrowania po dniu tygodnia."),
                                                        className="py-0"),
                                                    ])
                                                ],
                                            className="py-0"),
                                        ]
                                    ),
                                ]
                            ),
                            className="mb-3",
                        )
                    ],
                    width=9,
                    className="pe-3",
                ),

                dbc.Col([
                    dbc.Card(
                        dbc.CardBody(
                            [
                                dbc.ListGroup([
                                    dbc.ListGroupItem(
                                        html.H3("Wykorzystane technologie")
                                    ),
                                    dbc.ListGroupItem(
                                        html.A(html.Img(src="/assets/plotly.png", style={"width": "100%"}, className="special-plotly"), href="https://plotly.com/")
                                    ),
                                    dbc.ListGroupItem(
                                        html.A(html.Img(src="/assets/dash.png", style={"width": "100%"}), href="https://dash.plotly.com/")
                                    ),
                                    dbc.ListGroupItem(
                                        dbc.Row([
                                            dbc.Col(html.A(html.Img(src="/assets/python.png", style={"width": "100%"}), href="https://www.python.org/")),
                                            dbc.Col(html.A(html.Img(src="/assets/aw.png", style={"width": "100%"}), href="https://activitywatch.net/"))
                                        ])
                                    )
                                ])
                            ]
                        ),
                    className="o-padding-a"),
                    dbc.Card(
                        dbc.CardBody(
                            [
                                html.H3("Autorzy:"),
                                dbc.ListGroup([
                                    dbc.ListGroupItem(html.H5("● Kamil Janusiak")),
                                    dbc.ListGroupItem(html.H5("● Antoni Kobosz")),
                                    dbc.ListGroupItem(html.H5("● Jerzy Adrjan")),
                                    None if pd.Timestamp.now().strftime("%H%M") != "2026" else dbc.ListGroupItem(html.H5("● Jan Ryba"))
                                ]),
                                html.H6("Techniki Wizualizacji Danych  28 stycznia 2026")
                            ]
                        ),
                    className="o-padding-b")],  
                    width=3,
                    className="ps-3",
                ),
            ]
        ),
    ],
    fluid=True,
    className="intro-container"
)


# endregion
# endregion
if __name__ == "__main__":
    app.run(debug=True, port=8888)