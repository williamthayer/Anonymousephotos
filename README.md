# Field Notes photo gallery

The site is static and can be published from this repository with GitHub Pages. Supabase provides admin sign-in, image storage, and photo metadata.

## Connect Supabase

1. Create a Supabase project.
2. In the Supabase SQL Editor, run the contents of `supabase-setup.sql`.
3. In Supabase Authentication, add an admin user. Do not add a public sign-up form to this site.
4. Copy that user's UUID from Authentication > Users, then add it to the admin allowlist in the SQL Editor:

   ```sql
   insert into public.gallery_admins (user_id)
   values ('PASTE-ADMIN-USER-UUID-HERE');
   ```

5. In Supabase project settings, copy the Project URL and the public anon/publishable key into `supabase-config.js`:

   ```js
   window.FIELD_NOTES_SUPABASE = {
     url: "https://your-project.supabase.co",
     anonKey: "your-public-anon-or-publishable-key"
   };
   ```

6. Commit the site files and enable GitHub Pages for the repository's root folder.
7. Open the published site and choose **Admin sign in** to upload photos. Add a title, its destination URL, and comma-separated tags. The displayed title links to that URL; the title is also used as fallback image text.

If you already ran the setup SQL, run the updated `supabase-setup.sql` again after changes so the current storage policies are applied. Signed-in admins can edit tags or remove uploaded photos from the gallery.

The public key is intended for browser use. The SQL policies make the gallery readable publicly but allow writes only for user IDs in `gallery_admins`. Never put a Supabase `service_role` or secret key in this repository. Uploaded images are public because they appear in the public gallery. Before upload, the browser decodes each JPEG, PNG, WebP, or AVIF and re-encodes it as WebP, which removes embedded metadata such as EXIF GPS coordinates. This re-encoding is lossy at 92% quality; the resulting file must be under 10 MB.