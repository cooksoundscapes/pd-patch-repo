#include "m_pd.h"

static t_class* bomdiacaralho_class;

typedef struct _bomdiacaralho {
  t_object x_obj;
} t_bomdiacaralho;

void bomdiacaralho_bang(t_bomdiacaralho *x)
{
  post("BOMDIACARALHO");
}

void *bomdiacaralho_new(void)
{
  t_bomdiacaralho *x = (t_bomdiacaralho *)pd_new(bomdiacaralho_class);

  return (void *)x;
}

void  bomdiacaralho_setup(void) {
    bomdiacaralho_class = class_new(gensym("bomdiacaralho"),
        (t_newmethod)bomdiacaralho_new,
        0, sizeof(t_bomdiacaralho),
        CLASS_DEFAULT, 0);
    class_addbang(bomdiacaralho_class, bomdiacaralho_bang);
}