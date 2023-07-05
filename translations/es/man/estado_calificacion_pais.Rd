\docType{data}
\name{estado_calificacion_pais}
\alias{estado_calificacion_pais}
\title{Libertades Civiles y Derechos Políticos, 1972-2022}
\format{Un data.frame de 9.043 filas y 9 columnas
\describe{
\item{anio}{Año de la observación (1972-2022)}
\item{pais}{Nombre del país o territorio}
\item{iso2c}{Código ISO de dos dígitos del país o territorio. Abjasia, Crimea, Kosovo, Nagorno-Karabaj, Osetia del Sur, Palestina, Sahara Occidental y Transnistria no tienen una correspondencia inambigua y aparecen como 'NA'}
\item{iso3c}{Código ISO de tres dígitos del país o territorio. Sigue el mismo criterio para los 'NA' que la variable iso2c.}
\item{continente}{Nombre del continente.}
\item{derechos_politicos}{Calificación de derechos políticos (escala 1-7, con 1 representando el mayor grado de libertad y 7 el menor).}
\item{libertades_civiles}{Calificación de libertades civiles (escala 1-7, con 1 representando el mayor grado de libertad y 7 el menor).}
\item{estado}{Estado del país (Libre, Parcialmente Libre, No Libre).}
\item{color}{Color asociado al estado del país.}
}}
\usage{estado_calificacion_pais}
\description{Para cada país y territorio, La Libertad en el Mundo analiza el proceso electoral, el pluralismo y la participación política, el funcionamiento del gobierno, la libertad de expresión y de creencias, los derechos asociativos y organizativos, el estado de derecho, la autonomía personal y los derechos individuales.}
\source{Adaptado de Freedom House}
\keyword{datasets}
