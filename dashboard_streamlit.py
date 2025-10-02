import streamlit as st
import pandas as pd
import sqlite3
import plotly.express as px

# --- CONFIGURACIÓN DE LA PÁGINA ---
st.set_page_config(layout="wide", page_title="Dashboard de Análisis de Cohortes y RFM")

# --- CARGA DE DATOS ---
@st.cache_data
def load_data():
    con = sqlite3.connect("/Users/apple/Desktop/SABANA/Administración de negocios internacionales/Septimo Semestre/Bussiness intelligence/Corte 2/Cohors Analysis/carmax_FINAL.db")
    df = pd.read_sql_query("SELECT * FROM Unpivot_RFM_Cohort", con)
    con.close()
    return df

df = load_data()

# --- TÍTULO Y DESCRIPCIÓN ---
st.title("Dashboard de Análisis de Cohortes y RFM")
st.markdown("Una vista interactiva del comportamiento de los clientes a lo largo del tiempo.")

# --- FILTROS ---
st.sidebar.header("Filtros")
month_order = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
# Use pd.Categorical to sort months correctly
df['Fecha'] = pd.Categorical(df['Fecha'], categories=month_order, ordered=True)
months = sorted(df['Fecha'].unique())

selected_month = st.sidebar.selectbox("Selecciona un Mes", months)

segments = ['Todos'] + list(df['Estado'].unique())
selected_segment = st.sidebar.selectbox("Filtrar por Estado", segments)

# --- FILTRAR DATOS ---
filtered_df = df[df['Fecha'] == selected_month]
if selected_segment != 'Todos':
    filtered_df = filtered_df[filtered_df['Estado'] == selected_segment]

# --- GRÁFICOS ---

# Fila 1
col1, col2 = st.columns([3, 2])

with col1:
    st.subheader("Distribución de Estados de Clientes (Mes Seleccionado)")
    if not filtered_df.empty:
        status_counts = filtered_df['Estado'].value_counts().reset_index()
        status_counts.columns = ['Estado', 'count']
        fig_status = px.bar(status_counts, x='Estado', y='count', title="Conteo de Clientes por Estado", color='Estado', color_discrete_sequence=px.colors.qualitative.Plotly)
        st.plotly_chart(fig_status, use_container_width=True)
    else:
        st.warning("No hay datos para el mes y segmento seleccionados.")

with col2:
    st.subheader("Matriz de Estados por Mes (Cohorte)")
    cohort_data = df.groupby(['Fecha', 'Estado']).size().reset_index(name='count')
    cohort_pivot = cohort_data.pivot(index='Fecha', columns='Estado', values='count').fillna(0)
    # Ensure all months are present and sorted
    cohort_pivot = cohort_pivot.reindex(month_order, axis=0).fillna(0)
    fig_cohort = px.imshow(cohort_pivot, title="Clientes por Estado y Mes", text_auto=True, aspect="auto",
                           labels=dict(x="Estado del Cliente", y="Mes de Cohorte", color="Nº Clientes"),
                           color_continuous_scale=px.colors.sequential.Blues)
    fig_cohort.update_xaxes(side="top")
    st.plotly_chart(fig_cohort, use_container_width=True)

# Fila 2
st.subheader("Segmentación RFM (Mes Seleccionado)")
col_r, col_f, col_m = st.columns(3)

if not filtered_df.empty:
    with col_r:
        st.markdown("<h5 style='text-align: center;'>Recencia (R)</h5>", unsafe_allow_html=True)
        r_counts = filtered_df['R_label'].value_counts().reset_index()
        r_counts.columns = ['R_label', 'count']
        fig_r = px.pie(r_counts, names='R_label', values='count', hole=0.4, title="Distribución de Recencia")
        st.plotly_chart(fig_r, use_container_width=True)

    with col_f:
        st.markdown("<h5 style='text-align: center;'>Frecuencia (F)</h5>", unsafe_allow_html=True)
        f_counts = filtered_df['F_label'].value_counts().reset_index()
        f_counts.columns = ['F_label', 'count']
        fig_f = px.pie(f_counts, names='F_label', values='count', hole=0.4, title="Distribución de Frecuencia")
        st.plotly_chart(fig_f, use_container_width=True)

    with col_m:
        st.markdown("<h5 style='text-align: center;'>Gasto (M)</h5>", unsafe_allow_html=True)
        m_counts = filtered_df['M_label'].value_counts().reset_index()
        m_counts.columns = ['M_label', 'count']
        fig_m = px.pie(m_counts, names='M_label', values='count', hole=0.4, title="Distribución de Gasto")
        st.plotly_chart(fig_m, use_container_width=True)
else:
    st.warning("No hay datos de RFM para mostrar para la selección actual.")
