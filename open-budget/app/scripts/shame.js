window.up_or_down = (allocated, revised) => {
  if (allocated > revised) {
    return ['קטן', 'מ'];
  } else if (allocated < revised) {
    return ['הוגדל', 'מ'];
  }

  return ['עמד', 'על'];
};

window.increase_or_cut = (allocated, revised) => {
  if (allocated > revised) {
    return 'קיצוץ זה הביא';
  }

  return 'תוספת זו הביאה';
};
