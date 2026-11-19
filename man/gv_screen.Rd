\name{gv_screen}
\alias{gv_screen}
\title{Screening statistics for careless responding}
\usage{gv_screen(x, z = 2)}
\arguments{
\item{x}{object from gv_fit() (generation-verification model).}
\item{z}{threshold on the standardized posterior mean breadth used for flagging (default 2).}
}
\description{Careless responders occupy extreme positions in the posterior: random responders show very high breadth and very low verification ability, give-up responders very low breadth (simulation 3 of the accompanying article). This function standardizes each participant's posterior means against the estimated population and ranks participants by how extreme they are. It does not decide who is careless; inspect the flagged cases before excluding anyone.}
\value{person table from gv_persons() with `b_z`, `v_z`, `pattern` ("high breadth, low verification", "low breadth", or ""), ordered from most to least extreme.}
