/* HashTagList.c generated by valac 0.26.1.9-22126, the Vala compiler
 * generated from HashTagList.vala, do not modify */


#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
#include <stdlib.h>
#include <string.h>


#define PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST (photo_stream_widgets_hash_tag_list_get_type ())
#define PHOTO_STREAM_WIDGETS_HASH_TAG_LIST(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST, PhotoStreamWidgetsHashTagList))
#define PHOTO_STREAM_WIDGETS_HASH_TAG_LIST_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST, PhotoStreamWidgetsHashTagListClass))
#define PHOTO_STREAM_WIDGETS_IS_HASH_TAG_LIST(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST))
#define PHOTO_STREAM_WIDGETS_IS_HASH_TAG_LIST_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST))
#define PHOTO_STREAM_WIDGETS_HASH_TAG_LIST_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST, PhotoStreamWidgetsHashTagListClass))

typedef struct _PhotoStreamWidgetsHashTagList PhotoStreamWidgetsHashTagList;
typedef struct _PhotoStreamWidgetsHashTagListClass PhotoStreamWidgetsHashTagListClass;
typedef struct _PhotoStreamWidgetsHashTagListPrivate PhotoStreamWidgetsHashTagListPrivate;

#define PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_BOX (photo_stream_widgets_hash_tag_box_get_type ())
#define PHOTO_STREAM_WIDGETS_HASH_TAG_BOX(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_BOX, PhotoStreamWidgetsHashTagBox))
#define PHOTO_STREAM_WIDGETS_HASH_TAG_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_BOX, PhotoStreamWidgetsHashTagBoxClass))
#define PHOTO_STREAM_WIDGETS_IS_HASH_TAG_BOX(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_BOX))
#define PHOTO_STREAM_WIDGETS_IS_HASH_TAG_BOX_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_BOX))
#define PHOTO_STREAM_WIDGETS_HASH_TAG_BOX_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_BOX, PhotoStreamWidgetsHashTagBoxClass))

typedef struct _PhotoStreamWidgetsHashTagBox PhotoStreamWidgetsHashTagBox;
typedef struct _PhotoStreamWidgetsHashTagBoxClass PhotoStreamWidgetsHashTagBoxClass;
#define __g_list_free__g_object_unref0_0(var) ((var == NULL) ? NULL : (var = (_g_list_free__g_object_unref0_ (var), NULL)))
#define _g_object_unref0(var) ((var == NULL) ? NULL : (var = (g_object_unref (var), NULL)))
#define _g_free0(var) (var = (g_free (var), NULL))
#define _g_list_free0(var) ((var == NULL) ? NULL : (var = (g_list_free (var), NULL)))

#define PHOTO_STREAM_UTILS_TYPE_TAG (photo_stream_utils_tag_get_type ())
#define PHOTO_STREAM_UTILS_TAG(obj) (G_TYPE_CHECK_INSTANCE_CAST ((obj), PHOTO_STREAM_UTILS_TYPE_TAG, PhotoStreamUtilsTag))
#define PHOTO_STREAM_UTILS_TAG_CLASS(klass) (G_TYPE_CHECK_CLASS_CAST ((klass), PHOTO_STREAM_UTILS_TYPE_TAG, PhotoStreamUtilsTagClass))
#define PHOTO_STREAM_UTILS_IS_TAG(obj) (G_TYPE_CHECK_INSTANCE_TYPE ((obj), PHOTO_STREAM_UTILS_TYPE_TAG))
#define PHOTO_STREAM_UTILS_IS_TAG_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), PHOTO_STREAM_UTILS_TYPE_TAG))
#define PHOTO_STREAM_UTILS_TAG_GET_CLASS(obj) (G_TYPE_INSTANCE_GET_CLASS ((obj), PHOTO_STREAM_UTILS_TYPE_TAG, PhotoStreamUtilsTagClass))

typedef struct _PhotoStreamUtilsTag PhotoStreamUtilsTag;
typedef struct _PhotoStreamUtilsTagClass PhotoStreamUtilsTagClass;
typedef struct _PhotoStreamWidgetsHashTagBoxPrivate PhotoStreamWidgetsHashTagBoxPrivate;
typedef struct _PhotoStreamUtilsTagPrivate PhotoStreamUtilsTagPrivate;

struct _PhotoStreamWidgetsHashTagList {
	GtkListBox parent_instance;
	PhotoStreamWidgetsHashTagListPrivate * priv;
	GList* boxes;
	GtkButton* moreButton;
	gchar* olderFeedLink;
};

struct _PhotoStreamWidgetsHashTagListClass {
	GtkListBoxClass parent_class;
};

struct _PhotoStreamWidgetsHashTagBox {
	GtkEventBox parent_instance;
	PhotoStreamWidgetsHashTagBoxPrivate * priv;
	GtkBox* box;
	GtkAlignment* hashtagNameAlignment;
	GtkAlignment* mediaCountAlignment;
	GtkLabel* hashtagNameLabel;
	GtkLabel* mediaCountLabel;
	PhotoStreamUtilsTag* tag;
};

struct _PhotoStreamWidgetsHashTagBoxClass {
	GtkEventBoxClass parent_class;
};

struct _PhotoStreamUtilsTag {
	GTypeInstance parent_instance;
	volatile int ref_count;
	PhotoStreamUtilsTagPrivate * priv;
	gchar* tag;
	gint64 mediaCount;
};

struct _PhotoStreamUtilsTagClass {
	GTypeClass parent_class;
	void (*finalize) (PhotoStreamUtilsTag *self);
};


static gpointer photo_stream_widgets_hash_tag_list_parent_class = NULL;

GType photo_stream_widgets_hash_tag_list_get_type (void) G_GNUC_CONST;
GType photo_stream_widgets_hash_tag_box_get_type (void) G_GNUC_CONST;
enum  {
	PHOTO_STREAM_WIDGETS_HASH_TAG_LIST_DUMMY_PROPERTY
};
static void _g_object_unref0_ (gpointer var);
static void _g_list_free__g_object_unref0_ (GList* self);
PhotoStreamWidgetsHashTagList* photo_stream_widgets_hash_tag_list_new (void);
PhotoStreamWidgetsHashTagList* photo_stream_widgets_hash_tag_list_construct (GType object_type);
void photo_stream_widgets_hash_tag_list_addMoreButton (PhotoStreamWidgetsHashTagList* self);
void photo_stream_widgets_hash_tag_list_deleteMoreButton (PhotoStreamWidgetsHashTagList* self);
gpointer photo_stream_utils_tag_ref (gpointer instance);
void photo_stream_utils_tag_unref (gpointer instance);
GParamSpec* photo_stream_utils_param_spec_tag (const gchar* name, const gchar* nick, const gchar* blurb, GType object_type, GParamFlags flags);
void photo_stream_utils_value_set_tag (GValue* value, gpointer v_object);
void photo_stream_utils_value_take_tag (GValue* value, gpointer v_object);
gpointer photo_stream_utils_value_get_tag (const GValue* value);
GType photo_stream_utils_tag_get_type (void) G_GNUC_CONST;
gboolean photo_stream_widgets_hash_tag_list_contains (PhotoStreamWidgetsHashTagList* self, PhotoStreamUtilsTag* tag);
void photo_stream_widgets_hash_tag_list_append (PhotoStreamWidgetsHashTagList* self, PhotoStreamUtilsTag* tag);
PhotoStreamWidgetsHashTagBox* photo_stream_widgets_hash_tag_box_new (PhotoStreamUtilsTag* tag);
PhotoStreamWidgetsHashTagBox* photo_stream_widgets_hash_tag_box_construct (GType object_type, PhotoStreamUtilsTag* tag);
void photo_stream_widgets_hash_tag_list_prepend (PhotoStreamWidgetsHashTagList* self, PhotoStreamUtilsTag* tag);
void photo_stream_widgets_hash_tag_list_clear (PhotoStreamWidgetsHashTagList* self);
static void photo_stream_widgets_hash_tag_list_finalize (GObject* obj);


static void _g_object_unref0_ (gpointer var) {
#line 5 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	(var == NULL) ? NULL : (var = (g_object_unref (var), NULL));
#line 123 "HashTagList.c"
}


static void _g_list_free__g_object_unref0_ (GList* self) {
#line 5 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_list_foreach (self, (GFunc) _g_object_unref0_, NULL);
#line 5 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_list_free (self);
#line 132 "HashTagList.c"
}


PhotoStreamWidgetsHashTagList* photo_stream_widgets_hash_tag_list_construct (GType object_type) {
	PhotoStreamWidgetsHashTagList * self = NULL;
	GtkButton* _tmp0_ = NULL;
#line 8 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	self = (PhotoStreamWidgetsHashTagList*) g_object_new (object_type, NULL);
#line 10 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	__g_list_free__g_object_unref0_0 (self->boxes);
#line 10 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	self->boxes = NULL;
#line 11 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp0_ = (GtkButton*) gtk_button_new_with_label ("Load more...");
#line 11 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_object_ref_sink (_tmp0_);
#line 11 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_object_unref0 (self->moreButton);
#line 11 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	self->moreButton = _tmp0_;
#line 13 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	gtk_list_box_set_selection_mode ((GtkListBox*) self, GTK_SELECTION_NONE);
#line 14 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	gtk_list_box_set_activate_on_single_click ((GtkListBox*) self, FALSE);
#line 8 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	return self;
#line 159 "HashTagList.c"
}


PhotoStreamWidgetsHashTagList* photo_stream_widgets_hash_tag_list_new (void) {
#line 8 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	return photo_stream_widgets_hash_tag_list_construct (PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST);
#line 166 "HashTagList.c"
}


void photo_stream_widgets_hash_tag_list_addMoreButton (PhotoStreamWidgetsHashTagList* self) {
	GtkButton* _tmp0_ = NULL;
	gboolean _tmp1_ = FALSE;
#line 16 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_if_fail (self != NULL);
#line 18 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp0_ = self->moreButton;
#line 18 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp1_ = gtk_widget_is_ancestor ((GtkWidget*) _tmp0_, (GtkWidget*) self);
#line 18 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	if (!_tmp1_) {
#line 181 "HashTagList.c"
		GtkButton* _tmp2_ = NULL;
#line 19 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
		_tmp2_ = self->moreButton;
#line 19 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
		gtk_list_box_prepend (G_TYPE_CHECK_INSTANCE_CAST (self, gtk_list_box_get_type (), GtkListBox), (GtkWidget*) _tmp2_);
#line 187 "HashTagList.c"
	}
}


void photo_stream_widgets_hash_tag_list_deleteMoreButton (PhotoStreamWidgetsHashTagList* self) {
	GList* _tmp0_ = NULL;
	GList* _tmp1_ = NULL;
	GList* _tmp2_ = NULL;
	gconstpointer _tmp3_ = NULL;
#line 21 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_if_fail (self != NULL);
#line 23 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp0_ = gtk_container_get_children ((GtkContainer*) self);
#line 23 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp1_ = _tmp0_;
#line 23 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp2_ = g_list_last (_tmp1_);
#line 23 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp3_ = _tmp2_->data;
#line 23 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	gtk_container_remove ((GtkContainer*) self, (GtkWidget*) _tmp3_);
#line 23 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_list_free0 (_tmp1_);
#line 211 "HashTagList.c"
}


static gpointer _g_object_ref0 (gpointer self) {
#line 27 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	return self ? g_object_ref (self) : NULL;
#line 218 "HashTagList.c"
}


gboolean photo_stream_widgets_hash_tag_list_contains (PhotoStreamWidgetsHashTagList* self, PhotoStreamUtilsTag* tag) {
	gboolean result = FALSE;
	GList* _tmp0_ = NULL;
#line 25 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_val_if_fail (self != NULL, FALSE);
#line 25 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_val_if_fail (tag != NULL, FALSE);
#line 27 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp0_ = self->boxes;
#line 231 "HashTagList.c"
	{
		GList* box_collection = NULL;
		GList* box_it = NULL;
#line 27 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
		box_collection = _tmp0_;
#line 27 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
		for (box_it = box_collection; box_it != NULL; box_it = box_it->next) {
#line 239 "HashTagList.c"
			PhotoStreamWidgetsHashTagBox* _tmp1_ = NULL;
			PhotoStreamWidgetsHashTagBox* box = NULL;
#line 27 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
			_tmp1_ = _g_object_ref0 ((PhotoStreamWidgetsHashTagBox*) box_it->data);
#line 27 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
			box = _tmp1_;
#line 246 "HashTagList.c"
			{
				PhotoStreamWidgetsHashTagBox* _tmp2_ = NULL;
				PhotoStreamUtilsTag* _tmp3_ = NULL;
				const gchar* _tmp4_ = NULL;
				PhotoStreamUtilsTag* _tmp5_ = NULL;
				const gchar* _tmp6_ = NULL;
#line 28 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				_tmp2_ = box;
#line 28 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				_tmp3_ = _tmp2_->tag;
#line 28 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				_tmp4_ = _tmp3_->tag;
#line 28 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				_tmp5_ = tag;
#line 28 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				_tmp6_ = _tmp5_->tag;
#line 28 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				if (g_strcmp0 (_tmp4_, _tmp6_) == 0) {
#line 29 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
					result = TRUE;
#line 29 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
					_g_object_unref0 (box);
#line 29 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
					return result;
#line 271 "HashTagList.c"
				}
#line 27 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				_g_object_unref0 (box);
#line 275 "HashTagList.c"
			}
		}
	}
#line 31 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	result = FALSE;
#line 31 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	return result;
#line 283 "HashTagList.c"
}


void photo_stream_widgets_hash_tag_list_append (PhotoStreamWidgetsHashTagList* self, PhotoStreamUtilsTag* tag) {
	GtkSeparator* separator = NULL;
	GtkSeparator* _tmp0_ = NULL;
	PhotoStreamWidgetsHashTagBox* box = NULL;
	PhotoStreamUtilsTag* _tmp1_ = NULL;
	PhotoStreamWidgetsHashTagBox* _tmp2_ = NULL;
	PhotoStreamWidgetsHashTagBox* _tmp3_ = NULL;
#line 33 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_if_fail (self != NULL);
#line 33 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_if_fail (tag != NULL);
#line 35 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp0_ = (GtkSeparator*) gtk_separator_new (GTK_ORIENTATION_HORIZONTAL);
#line 35 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_object_ref_sink (_tmp0_);
#line 35 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	separator = _tmp0_;
#line 36 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	gtk_list_box_prepend (G_TYPE_CHECK_INSTANCE_CAST (self, gtk_list_box_get_type (), GtkListBox), (GtkWidget*) separator);
#line 37 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp1_ = tag;
#line 37 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp2_ = photo_stream_widgets_hash_tag_box_new (_tmp1_);
#line 37 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_object_ref_sink (_tmp2_);
#line 37 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	box = _tmp2_;
#line 38 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	gtk_list_box_prepend (G_TYPE_CHECK_INSTANCE_CAST (self, gtk_list_box_get_type (), GtkListBox), (GtkWidget*) box);
#line 39 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp3_ = _g_object_ref0 (box);
#line 39 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	self->boxes = g_list_append (self->boxes, _tmp3_);
#line 33 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_object_unref0 (box);
#line 33 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_object_unref0 (separator);
#line 324 "HashTagList.c"
}


void photo_stream_widgets_hash_tag_list_prepend (PhotoStreamWidgetsHashTagList* self, PhotoStreamUtilsTag* tag) {
	GtkSeparator* separator = NULL;
	GtkSeparator* _tmp0_ = NULL;
	GList* _tmp1_ = NULL;
	GList* _tmp2_ = NULL;
	guint _tmp3_ = 0U;
	PhotoStreamWidgetsHashTagBox* box = NULL;
	PhotoStreamUtilsTag* _tmp4_ = NULL;
	PhotoStreamWidgetsHashTagBox* _tmp5_ = NULL;
	GList* _tmp6_ = NULL;
	GList* _tmp7_ = NULL;
	guint _tmp8_ = 0U;
	PhotoStreamWidgetsHashTagBox* _tmp9_ = NULL;
#line 42 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_if_fail (self != NULL);
#line 42 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_if_fail (tag != NULL);
#line 44 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp0_ = (GtkSeparator*) gtk_separator_new (GTK_ORIENTATION_HORIZONTAL);
#line 44 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_object_ref_sink (_tmp0_);
#line 44 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	separator = _tmp0_;
#line 45 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp1_ = gtk_container_get_children ((GtkContainer*) self);
#line 45 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp2_ = _tmp1_;
#line 45 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp3_ = g_list_length (_tmp2_);
#line 45 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	gtk_list_box_insert (G_TYPE_CHECK_INSTANCE_CAST (self, gtk_list_box_get_type (), GtkListBox), (GtkWidget*) separator, ((gint) _tmp3_) - 1);
#line 45 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_list_free0 (_tmp2_);
#line 46 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp4_ = tag;
#line 46 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp5_ = photo_stream_widgets_hash_tag_box_new (_tmp4_);
#line 46 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_object_ref_sink (_tmp5_);
#line 46 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	box = _tmp5_;
#line 47 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp6_ = gtk_container_get_children ((GtkContainer*) self);
#line 47 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp7_ = _tmp6_;
#line 47 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp8_ = g_list_length (_tmp7_);
#line 47 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	gtk_list_box_insert (G_TYPE_CHECK_INSTANCE_CAST (self, gtk_list_box_get_type (), GtkListBox), (GtkWidget*) box, ((gint) _tmp8_) - 1);
#line 47 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_list_free0 (_tmp7_);
#line 48 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp9_ = _g_object_ref0 (box);
#line 48 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	self->boxes = g_list_append (self->boxes, _tmp9_);
#line 42 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_object_unref0 (box);
#line 42 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_object_unref0 (separator);
#line 387 "HashTagList.c"
}


void photo_stream_widgets_hash_tag_list_clear (PhotoStreamWidgetsHashTagList* self) {
	GList* _tmp0_ = NULL;
#line 51 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	g_return_if_fail (self != NULL);
#line 53 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_tmp0_ = gtk_container_get_children ((GtkContainer*) self);
#line 397 "HashTagList.c"
	{
		GList* child_collection = NULL;
		GList* child_it = NULL;
#line 53 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
		child_collection = _tmp0_;
#line 53 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
		for (child_it = child_collection; child_it != NULL; child_it = child_it->next) {
#line 405 "HashTagList.c"
			GtkWidget* child = NULL;
#line 53 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
			child = (GtkWidget*) child_it->data;
#line 409 "HashTagList.c"
			{
				GtkWidget* _tmp1_ = NULL;
#line 54 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				_tmp1_ = child;
#line 54 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
				gtk_container_remove ((GtkContainer*) self, _tmp1_);
#line 416 "HashTagList.c"
			}
		}
#line 53 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
		_g_list_free0 (child_collection);
#line 421 "HashTagList.c"
	}
#line 55 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	__g_list_free__g_object_unref0_0 (self->boxes);
#line 55 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	self->boxes = NULL;
#line 427 "HashTagList.c"
}


static void photo_stream_widgets_hash_tag_list_class_init (PhotoStreamWidgetsHashTagListClass * klass) {
#line 3 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	photo_stream_widgets_hash_tag_list_parent_class = g_type_class_peek_parent (klass);
#line 3 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	G_OBJECT_CLASS (klass)->finalize = photo_stream_widgets_hash_tag_list_finalize;
#line 436 "HashTagList.c"
}


static void photo_stream_widgets_hash_tag_list_instance_init (PhotoStreamWidgetsHashTagList * self) {
}


static void photo_stream_widgets_hash_tag_list_finalize (GObject* obj) {
	PhotoStreamWidgetsHashTagList * self;
#line 3 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	self = G_TYPE_CHECK_INSTANCE_CAST (obj, PHOTO_STREAM_WIDGETS_TYPE_HASH_TAG_LIST, PhotoStreamWidgetsHashTagList);
#line 5 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	__g_list_free__g_object_unref0_0 (self->boxes);
#line 6 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_object_unref0 (self->moreButton);
#line 7 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	_g_free0 (self->olderFeedLink);
#line 3 "/all/Documents/Programming/vala/photostream/src/Widgets/HashTagList.vala"
	G_OBJECT_CLASS (photo_stream_widgets_hash_tag_list_parent_class)->finalize (obj);
#line 456 "HashTagList.c"
}


GType photo_stream_widgets_hash_tag_list_get_type (void) {
	static volatile gsize photo_stream_widgets_hash_tag_list_type_id__volatile = 0;
	if (g_once_init_enter (&photo_stream_widgets_hash_tag_list_type_id__volatile)) {
		static const GTypeInfo g_define_type_info = { sizeof (PhotoStreamWidgetsHashTagListClass), (GBaseInitFunc) NULL, (GBaseFinalizeFunc) NULL, (GClassInitFunc) photo_stream_widgets_hash_tag_list_class_init, (GClassFinalizeFunc) NULL, NULL, sizeof (PhotoStreamWidgetsHashTagList), 0, (GInstanceInitFunc) photo_stream_widgets_hash_tag_list_instance_init, NULL };
		GType photo_stream_widgets_hash_tag_list_type_id;
		photo_stream_widgets_hash_tag_list_type_id = g_type_register_static (gtk_list_box_get_type (), "PhotoStreamWidgetsHashTagList", &g_define_type_info, 0);
		g_once_init_leave (&photo_stream_widgets_hash_tag_list_type_id__volatile, photo_stream_widgets_hash_tag_list_type_id);
	}
	return photo_stream_widgets_hash_tag_list_type_id__volatile;
}



